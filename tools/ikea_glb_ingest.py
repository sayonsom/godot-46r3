from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
import time
from collections import OrderedDict, deque
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable
from urllib.parse import urlsplit, urlunsplit

import requests
from bs4 import BeautifulSoup


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT_DIR = ROOT / "GLB" / "ikea"
DEFAULT_MANIFEST_PATH = DEFAULT_OUTPUT_DIR / "manifest.json"
SOURCE_REPOSITORY = "https://github.com/apinanaivot/IKEA-3d-model-batch-downloader"
USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36"
)
PRODUCT_URL_RE = re.compile(r"https://www\.ikea\.com/[^\"'?#\s]+/p/[^\"'?#\s]+/?")
PREFERRED_MODEL_SEGMENTS = ("rqp3", "rqp2", "rqp1", "simple")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "Download IKEA product GLBs into this Godot repo using the live site flow "
            "inspired by apinanaivot/IKEA-3d-model-batch-downloader, then decode the "
            "Draco-compressed assets into plain GLBs that Godot can import."
        )
    )
    parser.add_argument(
        "category_urls",
        nargs="+",
        help="One or more IKEA category URLs, ideally from the Finnish English site.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT_DIR,
        help=f"Directory for decoded GLBs. Default: {DEFAULT_OUTPUT_DIR}",
    )
    parser.add_argument(
        "--manifest-path",
        type=Path,
        default=DEFAULT_MANIFEST_PATH,
        help=f"Path to the JSON manifest. Default: {DEFAULT_MANIFEST_PATH}",
    )
    parser.add_argument(
        "--max-products",
        type=int,
        default=None,
        help="Stop after this many successfully downloaded GLBs.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Redownload and reconvert assets even if the decoded GLB already exists.",
    )
    parser.add_argument(
        "--request-timeout",
        type=float,
        default=30.0,
        help="Per-request timeout in seconds. Default: 30",
    )
    parser.add_argument(
        "--delay-seconds",
        type=float,
        default=0.1,
        help="Delay between processed product pages. Default: 0.1",
    )
    return parser


def canonicalize_url(url: str) -> str:
    parts = urlsplit(url)
    cleaned_path = parts.path.rstrip("/") + "/"
    return urlunsplit((parts.scheme, parts.netloc, cleaned_path, "", ""))


def category_key(url: str) -> str:
    path_parts = [part for part in urlsplit(url).path.split("/") if part]
    if not path_parts:
        return "category"
    return path_parts[-1]


def slug_from_product_url(url: str) -> str:
    return urlsplit(url).path.rstrip("/").split("/")[-1]


def article_number_from_slug(slug: str) -> str | None:
    match = re.search(r"-(\d{8,})$", slug)
    return match.group(1) if match else None


def relative_to_root(path: Path) -> str:
    try:
        return str(path.resolve().relative_to(ROOT))
    except ValueError:
        return str(path.resolve())


def load_manifest(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return {}


def save_manifest(path: Path, manifest: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(manifest, indent=2, sort_keys=False), encoding="utf-8")


def make_session() -> requests.Session:
    session = requests.Session()
    session.headers.update({"User-Agent": USER_AGENT})
    return session


def fetch_html(session: requests.Session, url: str, timeout: float) -> str:
    last_error: Exception | None = None
    for attempt in range(3):
        try:
            response = session.get(url, timeout=timeout)
            response.raise_for_status()
            return response.text
        except requests.RequestException as exc:
            last_error = exc
            if attempt == 2:
                break
            time.sleep(1.0 + attempt)
    assert last_error is not None
    raise last_error


def extract_product_urls(category_html: str) -> list[str]:
    product_urls: list[str] = []
    seen: set[str] = set()
    for match in PRODUCT_URL_RE.finditer(category_html):
        product_url = canonicalize_url(match.group(0))
        if product_url in seen:
            continue
        seen.add(product_url)
        product_urls.append(product_url)
    return product_urls


def iter_json_ld_nodes(value: Any) -> Iterable[dict[str, Any]]:
    if isinstance(value, list):
        for item in value:
            yield from iter_json_ld_nodes(item)
        return
    if not isinstance(value, dict):
        return
    yield value
    graph = value.get("@graph")
    if isinstance(graph, list):
        for item in graph:
            yield from iter_json_ld_nodes(item)


def load_json_ld_blocks(html: str) -> list[dict[str, Any]]:
    soup = BeautifulSoup(html, "html.parser")
    nodes: list[dict[str, Any]] = []
    for script in soup.find_all("script", attrs={"type": "application/ld+json"}):
        raw = script.string or script.get_text()
        if not raw:
            continue
        try:
            parsed = json.loads(raw)
        except json.JSONDecodeError:
            continue
        for node in iter_json_ld_nodes(parsed):
            nodes.append(node)
    return nodes


def is_type(node: dict[str, Any], expected: str) -> bool:
    value = node.get("@type")
    if isinstance(value, list):
        return expected in value
    return value == expected


def choose_model_url(model_urls: list[str]) -> str | None:
    if not model_urls:
        return None

    def rank(url: str) -> tuple[int, str]:
        lowered = url.lower()
        for index, marker in enumerate(PREFERRED_MODEL_SEGMENTS):
            if f"/{marker}/" in lowered or f"_{marker}_" in lowered:
                return index, lowered
        return len(PREFERRED_MODEL_SEGMENTS), lowered

    return sorted(model_urls, key=rank)[0]


def extract_product_metadata(product_html: str, product_url: str) -> dict[str, Any]:
    nodes = load_json_ld_blocks(product_html)
    product_name = slug_from_product_url(product_url)
    for node in nodes:
        if is_type(node, "Product"):
            name = node.get("name")
            if isinstance(name, str) and name.strip():
                product_name = name.strip()
                break

    model_urls: list[str] = []
    for node in nodes:
        if not is_type(node, "3DModel"):
            continue
        encodings = node.get("encoding", [])
        if isinstance(encodings, dict):
            encodings = [encodings]
        for encoding in encodings:
            if not isinstance(encoding, dict):
                continue
            content_url = encoding.get("contentUrl")
            if isinstance(content_url, str) and content_url.lower().endswith(".glb?cn=pip"):
                model_urls.append(content_url)
            elif isinstance(content_url, str) and ".glb" in content_url.lower():
                model_urls.append(content_url)

    model_url = choose_model_url(model_urls)
    slug = slug_from_product_url(product_url)
    return {
        "slug": slug,
        "article_number": article_number_from_slug(slug),
        "product_name": product_name,
        "product_url": product_url,
        "source_glb_url": model_url,
        "source_model_urls": model_urls,
    }


def download_file(session: requests.Session, url: str, destination: Path, timeout: float) -> None:
    with session.get(url, timeout=timeout, stream=True) as response:
        response.raise_for_status()
        with destination.open("wb") as handle:
            for chunk in response.iter_content(chunk_size=1024 * 1024):
                if chunk:
                    handle.write(chunk)


def ensure_npx_available() -> None:
    if shutil.which("npx"):
        return
    raise RuntimeError("npx is required to decode Draco GLBs. Install Node.js/npm first.")


def decode_draco_glb(compressed_path: Path, decoded_path: Path) -> None:
    ensure_npx_available()
    decoded_path.parent.mkdir(parents=True, exist_ok=True)
    command = [
        "npx",
        "--yes",
        "@gltf-transform/cli",
        "copy",
        str(compressed_path),
        str(decoded_path),
    ]
    completed = subprocess.run(command, capture_output=True, text=True, check=False)
    if completed.returncode == 0:
        return
    stderr = completed.stderr.strip()
    stdout = completed.stdout.strip()
    raise RuntimeError(stderr or stdout or "gltf-transform copy failed")


def build_manifest_header(category_urls: list[str], output_dir: Path) -> dict[str, Any]:
    return {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source_repository": SOURCE_REPOSITORY,
        "source_site": "https://www.ikea.com/fi/en/",
        "output_dir": relative_to_root(output_dir),
        "decoder": "npx --yes @gltf-transform/cli copy",
        "items": [],
        "errors": [],
        "categories": category_urls,
    }


def build_processing_queue(category_to_urls: OrderedDict[str, list[str]]) -> list[tuple[str, str]]:
    pending = OrderedDict((category, deque(urls)) for category, urls in category_to_urls.items())
    seen: set[str] = set()
    queue: list[tuple[str, str]] = []
    while pending:
        next_pending: OrderedDict[str, deque[str]] = OrderedDict()
        for category, urls in pending.items():
            while urls:
                product_url = urls.popleft()
                if product_url in seen:
                    continue
                seen.add(product_url)
                queue.append((category, product_url))
                break
            if urls:
                next_pending[category] = urls
        pending = next_pending
    return queue


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(line_buffering=True)
    args = build_parser().parse_args()
    output_dir = args.output_dir.resolve()
    manifest_path = args.manifest_path.resolve()
    session = make_session()

    existing_manifest = load_manifest(manifest_path)
    existing_items = {
        item.get("slug"): item
        for item in existing_manifest.get("items", [])
        if isinstance(item, dict) and item.get("slug")
    }
    manifest = build_manifest_header(args.category_urls, output_dir)
    kept_existing_items: dict[str, dict[str, Any]] = {}
    for slug, item in existing_items.items():
        output_file = item.get("output_file")
        if not isinstance(output_file, str):
            continue
        candidate = ROOT / output_file
        if candidate.exists():
            kept_existing_items[slug] = dict(item)

    category_to_urls: OrderedDict[str, list[str]] = OrderedDict()
    print("Scanning IKEA category pages...")
    for raw_url in args.category_urls:
        category_url = canonicalize_url(raw_url)
        key = category_key(category_url)
        try:
            html = fetch_html(session, category_url, args.request_timeout)
        except Exception as exc:
            message = f"{category_url}: {exc}"
            print(f"  ERROR {message}")
            manifest["errors"].append(message)
            continue
        product_urls = extract_product_urls(html)
        category_to_urls[key] = product_urls
        print(f"  {key}: discovered {len(product_urls)} product pages")

    processing_queue = build_processing_queue(category_to_urls)
    if not processing_queue:
        print("No product pages were discovered.")
        manifest["items"] = sorted(kept_existing_items.values(), key=lambda item: item["slug"])
        save_manifest(manifest_path, manifest)
        return 1

    print(f"Processing up to {args.max_products or len(processing_queue)} IKEA product pages...")
    successful = 0
    skipped_existing = 0
    skipped_without_model = 0
    failures = 0

    for index, (category, product_url) in enumerate(processing_queue, start=1):
        if args.max_products is not None and successful >= args.max_products:
            break

        print(f"[{index}/{len(processing_queue)}] {category} :: {product_url}")
        try:
            product_html = fetch_html(session, product_url, args.request_timeout)
            metadata = extract_product_metadata(product_html, product_url)
        except Exception as exc:
            failures += 1
            message = f"{product_url}: failed to inspect product page ({exc})"
            print(f"  ERROR {message}")
            manifest["errors"].append(message)
            continue

        slug = metadata["slug"]
        decoded_path = output_dir / f"{slug}.glb"
        metadata["category"] = category
        metadata["output_file"] = relative_to_root(decoded_path)
        metadata["downloaded_at"] = datetime.now(timezone.utc).isoformat()
        metadata["decoded_for_godot"] = True

        if not metadata["source_glb_url"]:
            skipped_without_model += 1
            print("  no 3D model found on page")
            continue

        if decoded_path.exists() and not args.overwrite:
            skipped_existing += 1
            print(f"  keeping existing {relative_to_root(decoded_path)}")
            existing = dict(existing_items.get(slug, {}))
            existing.update(metadata)
            existing["file_size_bytes"] = decoded_path.stat().st_size
            kept_existing_items[slug] = existing
            continue

        try:
            with tempfile.TemporaryDirectory(prefix="ikea-glb-") as tmp_dir:
                tmp_root = Path(tmp_dir)
                compressed_path = tmp_root / f"{slug}.draco.glb"
                print("  downloading source GLB...")
                download_file(session, metadata["source_glb_url"], compressed_path, args.request_timeout)
                print("  decoding Draco mesh compression...")
                decode_draco_glb(compressed_path, decoded_path)
        except Exception as exc:
            failures += 1
            message = f"{product_url}: failed to download or decode model ({exc})"
            print(f"  ERROR {message}")
            manifest["errors"].append(message)
            continue

        metadata["file_size_bytes"] = decoded_path.stat().st_size
        kept_existing_items[slug] = metadata
        successful += 1
        print(f"  wrote {relative_to_root(decoded_path)}")

        if args.delay_seconds > 0:
            time.sleep(args.delay_seconds)

    manifest["items"] = sorted(kept_existing_items.values(), key=lambda item: item["slug"])
    manifest["summary"] = {
        "downloaded_new": successful,
        "skipped_existing": skipped_existing,
        "skipped_without_model": skipped_without_model,
        "failures": failures,
        "tracked_items": len(manifest["items"]),
    }
    save_manifest(manifest_path, manifest)

    print("")
    print("Completed IKEA GLB ingestion.")
    print(f"  output_dir: {relative_to_root(output_dir)}")
    print(f"  manifest:   {relative_to_root(manifest_path)}")
    print(f"  downloaded new: {successful}")
    print(f"  skipped existing: {skipped_existing}")
    print(f"  skipped without model: {skipped_without_model}")
    print(f"  failures: {failures}")
    return 0 if successful > 0 or manifest["items"] else 1


if __name__ == "__main__":
    sys.exit(main())
