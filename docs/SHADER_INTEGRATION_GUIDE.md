# SmartThings 3D Home — Shader Integration Guide

A comprehensive, self-contained guide for reusing the visual-effect shaders from this Godot 4.6 Android app inside **any other Android application** — whether that host app is built on Godot, Unity, Unreal, a raw OpenGL ES / Vulkan renderer, or a WebView / Jetpack-Compose surface using a GLSL-capable runtime.

> **Scope.** Only the effect shaders actually used by this project are covered here. Floor-pattern, wall, furniture and icon shaders are deliberately out of scope.
>
> **Heads-up on naming.** There is **no "camera effect" or "energy effect" shader** in this project. If you were promised those, they do not exist in source. The visual effects that *do* exist, and are covered below, are:
>
> | # | Effect | Source file | Shader type |
> |---|---|---|---|
> | 1 | **Light glow** (halo + core disc for smart bulbs) | `shaders/device_light_glow.gdshader` | `spatial`, additive |
> | 2 | **Light cloud** (soft volumetric puff around a bulb) | `shaders/device_light_cloud.gdshader` | `spatial`, additive, fresnel-based |
> | 3 | **Air-conditioner pin wave** (cool blue sine-waves inside the AC pin) | `shaders/device_ac_pin_wave.gdshader` | `canvas_item`, blend-mix |
> | 4 | **Temperature / heatmap wash** (radial cool→warm floor gradient) | `shaders/device_temperature_wash.gdshader` | `spatial`, unshaded, blend-mix |
> | 5 | **Air-purifier / air-quality room tint** (colored floor with moving noise + source highlight) | `shaders/air_quality_room_tint.gdshader` | `spatial`, unshaded, blend-mix |
> | 6 | **Light-focus wash** (flat dimming scrim used when one bulb is selected) | `shaders/light_focus_wash.gdshader` | `spatial`, unshaded, blend-mix |
>
> If your host app happens to render a **camera device pin**, today it reuses the same pin-body material (no custom shader) — there is no camera-specific GPU effect to port. If you need a camera-style "live-view" shader, add one on your side and follow the same integration pattern described below.

---

## 1. Three integration paths

Pick one — they are listed cheapest-to-reuse first.

### Path A — Host Godot as an Android library (recommended)

The cleanest path. Godot 4.x can be embedded in an Android app as a library (`godot-lib.aar`) that renders into a `SurfaceView` / `FragmentContainerView`. You ship the shaders *as Godot resources* and drive them via GDScript or via the Java/Kotlin ↔ GDScript bridge. No GLSL porting required. This is exactly how the reference app integrates with its `android-app/` wrapper — see the companion doc for that bridge pattern.

**You get for free:** all `uniform` declarations, Godot's `ShaderMaterial` parameter binding, `SubViewport → 3D texture` pattern for callouts, and `render_priority` ordering.

**When to pick it.** If your host app is a visualization / dashboard / 3D floorplan and you want *exactly* the same look.

### Path B — Port the GLSL to your engine of choice

The shaders are short (the longest is ~95 lines) and written in a dialect that is ~95% stock GLSL 3.30. The only Godot-isms to rewrite are:

- `shader_type spatial;` / `canvas_item;` → your engine's equivalent pass
- `render_mode unshaded, blend_add, cull_disabled, depth_draw_never;` → pipeline state (disable depth write, additive blend, no cull)
- `ALBEDO`, `EMISSION`, `ALPHA`, `COLOR`, `UV`, `NORMAL`, `VIEW`, `VERTEX`, `TIME`, `TAU` → the builtins named in §4
- `source_color` hint → just a `vec4` uniform; treat as sRGB in your host
- `hint_range(min,max)` → metadata only; drop or map to UI sliders

**Target-engine cheat sheet:**

| Target | Translate to |
|---|---|
| Unity (URP) | `Shader "..."` with a `HLSLPROGRAM` pass; replace builtins with `_Time.y`, `TRANSFORM_TEX`, `ALBEDO→o.Albedo`. Use `Blend One One` for additive. |
| Unreal | Material → Translucent domain, Blend Mode Additive/Translucent, Unlit shading model. Rebuild the math in the node graph or a Custom HLSL node. |
| Raw OpenGL ES 3.0 (Android) | Drop the shader body into `main()` of a fragment shader; feed `UV`, `TIME`, etc. as your own `in` variables / uniforms. See §5 for a working Android GLES skeleton. |
| Jetpack Compose (`AGSL` / `RuntimeShader`, API 33+) | Port the fragment body to AGSL. Note: Compose runs at `canvas_item` complexity only — it is the natural target for the **AC pin wave** (2D). Do not use it for the spatial shaders. |
| Filament (Google's PBR engine) | Use `.mat` material package with `shadingModel : unlit`, `blending : add` / `transparent`. |

### Path C — Use the shader as a reference, rebuild natively

Some effects (light glow, AC pin wave) are visually simple enough that a native implementation with `VectorDrawable` + `PropertyAnimator` or Compose `drawBehind { }` may be enough, especially if the GPU cost of a full shader is unwanted on low-end Android devices. Treat the GLSL as a spec.

---

## 2. Effect-by-effect reference

Every subsection below gives you, for one shader: **purpose**, **shader type & render state**, **required mesh/surface**, **every uniform with its range & default**, **Godot binding snippet**, and **porting notes**.

### 2.1 Light glow — `device_light_glow.gdshader`

**Purpose.** Sits under a smart-bulb pin as a soft golden halo plus a brighter core disc. Pulses gently and shimmers so it doesn't feel baked-in.

**Shader type / render state.** `spatial, unshaded, blend_add, cull_disabled, depth_draw_never`. The mesh is a thin horizontal quad / disc placed just above the floor (the reference uses an N-gon disc of radius 2.78 m at Y ≈ 0.005 m). Because it is additive with depth write off, it *augments* whatever is beneath it and never z-fights the floor.

**Uniforms.**

| Name | Type | Range | Default | Meaning |
|---|---|---|---|---|
| `glow_color` | `vec4` (sRGB) | — | `(1.00, 0.84, 0.45, 1)` | Outer halo tint |
| `core_color` | `vec4` (sRGB) | — | `(1.00, 0.96, 0.76, 1)` | Bright disc tint |
| `intensity` | float | 0–3 | 1.2 | Master brightness |
| `ellipse` | float | 0.5–2 | 1.18 | Squash in UV-Y → oval vs. circle |
| `softness` | float | 0.8–4 | 2.0 | Halo falloff exponent (higher = softer) |
| `core_power` | float | 2–8 | 4.8 | Core disc falloff (higher = tighter) |
| `halo_extent` | float | 0.9–1.6 | 1.18 | Outer radius as fraction of UV |
| `alpha_strength` | float | 0.1–1.5 | 0.88 | Opacity multiplier before additive blend |
| `pulse_strength` | float | 0–0.5 | 0.04 | Pulse depth |
| `pulse_speed` | float | 0–8 | 2.1 | Pulse frequency (rad/s ≈ `sin(TIME*speed)`) |

**Godot binding (see `scripts/device_pin.gd:1058` for the real call site):**

```gdscript
var m := ShaderMaterial.new()
m.shader = preload("res://shaders/device_light_glow.gdshader")
m.set_shader_parameter("intensity", 0.48)
m.set_shader_parameter("glow_color", Color(1.0, 0.86, 0.48, 1.0))
m.set_shader_parameter("core_color", Color(1.0, 0.98, 0.82, 1.0))
m.set_shader_parameter("ellipse", 1.0)
m.set_shader_parameter("softness", 2.3)
m.set_shader_parameter("core_power", 4.4)
m.set_shader_parameter("halo_extent", 1.12)
m.set_shader_parameter("alpha_strength", 0.26)
m.set_shader_parameter("pulse_strength", 0.03)
m.set_shader_parameter("pulse_speed", 1.48)
mesh_instance.material_override = m
```

**Porting notes.** The shader only needs `UV` (0..1) and `TIME`. There is no lighting calculation, no world-space math. A plain textured quad in any engine is enough. For stacked layers (outer + inner + aura), the reference app uses **three** instances of the same shader with different parameters and `render_priority` values 13/14/15 to control draw order — reproduce that ordering on your side (draw furthest-from-camera first, or use sorted-transparent with manual priority).

---

### 2.2 Light cloud — `device_light_cloud.gdshader`

**Purpose.** Adds a soft volumetric puff around the bulb that fattens at grazing angles, using a fresnel-like term `abs(dot(NORMAL, VIEW))`.

**Shader type / render state.** `spatial, unshaded, blend_add, cull_disabled, depth_draw_never`. The mesh is a sphere / squashed ellipsoid around the bulb.

**Uniforms.**

| Name | Type | Range | Default | Meaning |
|---|---|---|---|---|
| `glow_color` | vec4 | — | `(1.00, 0.85, 0.55, 1)` | Outer puff |
| `core_color` | vec4 | — | `(1.00, 0.97, 0.82, 1)` | Inner hot-spot |
| `intensity` | float | 0–5 | 1.55 | Master brightness |
| `density` | float | 0.5–6 | 2.3 | Fresnel exponent — higher = thinner rim |
| `core_strength` | float | 0–3 | 1.1 | Extra hotspot boost |
| `vertical_bias` | float | -1..1 | 0.18 | Fades the lower hemisphere of the sphere |
| `pulse_speed` | float | 0–8 | 1.25 | Pulse frequency |
| `pulse_strength` | float | 0–0.3 | 0.055 | Pulse depth |

**Porting notes.** Requires `NORMAL` and `VIEW` (view-space view vector). In HLSL: `normalize(i.normalWS)` and `normalize(_WorldSpaceCameraPos - i.posWS)`. In GLES: pass both as `varying`s from the vertex stage.

---

### 2.3 Air-conditioner pin wave — `device_ac_pin_wave.gdshader`

**Purpose.** The cool-blue sine-wave animation that lives inside the AC device pin — two horizontal waves crossing the pin with a soft glow outline. This is the *only* 2D (`canvas_item`) shader in the set.

**Shader type / render state.** `canvas_item, blend_mix`. Drawn on a `ColorRect` / any 2D quad inside a `SubViewport` (the reference uses a 256×332 pin viewport — see `scripts/device_pin.gd:401`).

**Uniforms.**

| Name | Type | Range | Default | Meaning |
|---|---|---|---|---|
| `wave_color` | vec4 | — | `(0.23, 0.69, 0.93, 0.92)` | Wave line color |
| `glow_color` | vec4 | — | `(0.52, 0.88, 1.00, 0.34)` | Outer glow around each line |
| `speed` | float | 0–4 | 1.24 | Wave travel speed |
| `amplitude` | float | 0–0.12 | 0.054 | Peak-to-center offset in UV-Y |
| `cycles` | float | 0.5–3 | 1.28 | How many sine cycles across the pin |
| `line_thickness` | float | 0.005–0.06 | 0.024 | Core line half-width in UV |
| `glow_thickness` | float | 0.01–0.12 | 0.068 | Glow half-width in UV |
| `softness` | float | 0.002–0.05 | 0.014 | Core edge softness |
| `horizontal_padding` | float | 0–0.3 | 0.08 | Fade-in/out at left/right edges |
| `vertical_center_a` | float | 0.1–0.9 | 0.34 | Vertical UV of upper wave |
| `vertical_center_b` | float | 0.1–0.9 | 0.68 | Vertical UV of lower wave |

**Godot binding:**

```gdscript
var wave_material := ShaderMaterial.new()
wave_material.shader = preload("res://shaders/device_ac_pin_wave.gdshader")
wave_material.set_shader_parameter("wave_color",  Color(0.2, 0.67, 0.92, 0.94))
wave_material.set_shader_parameter("glow_color",  Color(0.53, 0.88, 1.0, 0.3))
wave_material.set_shader_parameter("speed", 1.24)
wave_material.set_shader_parameter("amplitude", 0.054)
wave_material.set_shader_parameter("cycles", 1.28)
# ...
color_rect.material = wave_material
```

**Porting notes.** Trivial to put behind a `RuntimeShader` (AGSL) in Jetpack Compose. Skeleton:

```kotlin
val agsl = """
uniform float2 size;
uniform float  time;
uniform float4 waveColor; uniform float4 glowColor;
uniform float  speed, amplitude, cycles, lineThickness, glowThickness,
               softness, horizontalPadding, vcA, vcB;
half4 main(float2 frag) {
    float2 uv = frag / size;
    float waveOffset = sin((uv.x - 0.5) * 6.2831853 * cycles - time * speed) * amplitude;
    // ...rest of body, 1:1 from GLSL...
}
""".trimIndent()

val shader = RuntimeShader(agsl).apply {
    setFloatUniform("size", w, h)
    setFloatUniform("time", t)
    setColorUniform("waveColor", 0x92EDB1F0.toInt())
    // ...
}
paint.shader = shader
canvas.drawRect(bounds, paint)
```

---

### 2.4 Temperature / heatmap wash — `device_temperature_wash.gdshader`

**Purpose.** The radial floor wash under the AC pin that interpolates color from **centre-temperature** to **wall-temperature** across the room, through a 7-stop palette (deep-cold → cool → cozy → cozy-warm → warm → hot → fever).

**Shader type / render state.** `spatial, unshaded, blend_mix, cull_disabled, depth_draw_never`. The mesh is a horizontal floor patch sized to the room polygon, sitting at `y = 0.0052 m`, with `render_priority = -4` so it draws after normal floors but under pins.

**Uniforms.**

| Name | Type | Default | Meaning |
|---|---|---|---|
| `center_temperature` | float | 24.0 | °C at the centre of the wash |
| `wall_temperature`   | float | 25.0 | °C at the room walls |
| `center_position`    | vec2  | (0,0) | Centre in **local-XZ space** (`VERTEX.xz`) |
| `room_extent`        | float | 3.0   | Distance (in mesh local units) where the colour reaches `wall_temperature` |
| `tint_alpha`         | float | 0.88  | Opacity |
| `gradient_curve`     | float | 1.35  | `pow(ratio, curve)` — shapes the falloff |
| `noise_scale/strength/speed/temp_jitter` | float | 1.6 / 0.03 / 0.12 / 0.35 | Animated 2-D value noise |
| `center_highlight_strength/radius` | float | 0.08 / 0.8 | Subtle bright spot under the pin |
| `deep_cold/cool/cozy/cozy_warm/warm/hot/fever_color` | vec4 | — | The seven palette stops |

**Godot binding (see `scripts/device_pin.gd:1122`):**

```gdscript
material.set_shader_parameter("center_temperature", 24.0)
material.set_shader_parameter("wall_temperature", 25.0)
material.set_shader_parameter("center_position", Vector2.ZERO)
material.set_shader_parameter("room_extent", room_extent_meters)
material.set_shader_parameter("tint_alpha", 0.88)
material.set_shader_parameter("gradient_curve", 1.35)
material.set_shader_parameter("center_highlight_strength", 0.10)
material.set_shader_parameter("center_highlight_radius", maxf(room_extent_meters * 0.45, 0.5))
# ...
```

**Porting notes.** The shader samples `VERTEX.xz` via a `varying` — this is mesh-local space. In your engine, pass `vPosLocal.xz` from VS to FS. The palette is entirely in uniforms, so you can retune it without recompiling.

---

### 2.5 Air-purifier / air-quality room tint — `air_quality_room_tint.gdshader`

**Purpose.** Tints the whole room floor with a color keyed to the air-quality state (green = good, yellow/orange = moderate, red = poor — the colors are provided by the controller script, not baked in). Adds a gentle brightening near the purifier pin and animated noise so it doesn't look painted-on.

**Shader type / render state.** Same as 2.4.

**Uniforms.**

| Name | Type | Default | Meaning |
|---|---|---|---|
| `tint_color` | vec4 | `(0.42, 0.82, 0.56, 1)` | Base room color |
| `highlight_color` | vec4 | `(0.62, 0.92, 0.76, 1)` | Brightened tint near the source |
| `tint_alpha` | float | 0.82 | Opacity |
| `source_position` | vec2 | (0,0) | Local-XZ position of the purifier pin |
| `highlight_radius` | float | 1.2 | Reach of the brightening |
| `highlight_strength` | float | 0.35 | How much to lerp toward `highlight_color` |
| `noise_scale/strength/speed` | float | 1.6 / 0.06 / 0.12 | Animated noise |

**Palettes used by the reference app** (`scripts/air_purifier.gd:304-326`):

```gdscript
# good
{ "tint_color": Color(0.42, 0.85, 0.52, 1.0), "highlight_color": Color(0.68, 0.96, 0.72, 1.0) }
# moderate
{ "tint_color": Color(0.98, 0.58, 0.36, 1.0), "highlight_color": Color(1.00, 0.72, 0.52, 1.0) }
# poor
{ "tint_color": Color(0.92, 0.36, 0.28, 1.0), "highlight_color": Color(1.00, 0.56, 0.42, 1.0) }
```

**Porting notes.** This is structurally identical to 2.4 — `VERTEX.xz` varying, same noise function, same render state. If you already ported the heatmap shader, this one is a 5-minute job.

---

### 2.6 Light-focus wash — `light_focus_wash.gdshader`

**Purpose.** Flat translucent scrim used as a dimming veil when the user focuses one bulb. It is *deliberately* a 5-line shader — a solid color with alpha.

```glsl
shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never;
uniform vec4 wash_color : source_color = vec4(0.43, 0.44, 0.47, 0.5);
void fragment() { ALBEDO = wash_color.rgb; ALPHA = wash_color.a; }
```

You almost certainly don't need to port this — any engine's "plain translucent unlit" material achieves the same thing. It is included for completeness.

---

## 3. Drop-in: how to copy the shaders into another Godot-based Android app

This is the happy path. Five steps:

1. **Copy the files.** Copy the six `.gdshader` files (and their `.gdshader.uid` twins) from `shaders/` into your target project. Preserve relative paths if you can, e.g. `res://shaders/effects/`. The `.uid` files are harmless but Godot 4.6 regenerates them on import — you can delete and let it reimport if paths change.

2. **Wire a `ShaderMaterial`.** For each effect create the material as shown in §2. You can do this either in GDScript (runtime) or in a `.tres` saved material.

3. **Attach to the right surface.**
   - Light glow / cloud / temperature / air-quality / focus-wash → `MeshInstance3D.material_override`.
   - AC pin wave → any `CanvasItem`'s `material` (`ColorRect`, `Sprite2D`, etc.), ideally inside a `SubViewport` so it can composite into a 3D pin via `SubViewportContainer` / `Sprite3D`.

4. **Respect render-priority.** The spatial effects are additive/transparent — they rely on back-to-front ordering. The reference uses explicit `render_priority` values (13–16 for glow layers, -4 for the temperature wash). If your host app already tunes priorities, merge yours in; do not leave them at 0.

5. **Drive parameters from your controller.** `set_shader_parameter(name, value)` per-frame (for `center_temperature` etc.) or once at setup. These shaders are designed so every aesthetic knob is a uniform — **do not fork the GLSL** to change colors; change the uniform from the controller.

---

## 4. Godot → generic GLSL builtin mapping

When porting to a non-Godot engine, these are the only builtins the shaders use:

| Godot builtin | Meaning | GLSL / HLSL equivalent |
|---|---|---|
| `UV` | vec2 surface UV, 0..1 | `in vec2 uv;` / `i.uv` |
| `NORMAL` | view-space normal (spatial) | `mat3(view) * normalWS` |
| `VIEW` | view-space view vector | `normalize(-posVS)` |
| `VERTEX` | vertex position, in view space by default, **but in local space when `render_mode` doesn't transform** — in these shaders `VERTEX.xz` is used inside `vertex()`, which runs before world transform → it is **local/model space**. | `in vec3 posLocal;` from your VS |
| `TIME` | seconds since engine start | `uniform float uTime;` |
| `TAU` | `6.2831853` | literal |
| `ALBEDO` | output base color (unshaded → final RGB when `unshaded`) | `fragColor.rgb` |
| `EMISSION` | added to ALBEDO when not unshaded; with `unshaded+blend_add` becomes the *only* contribution | add to `fragColor.rgb` |
| `ALPHA` | output alpha | `fragColor.a` |
| `COLOR` (2D) | canvas_item output | `fragColor` |

**Uniform hint semantics.**
- `source_color` — treat the vec4 as sRGB-encoded; convert to linear before use if your pipeline is linear.
- `hint_range(min, max)` — metadata for Godot's inspector; ignore at porting time.

---

## 5. Worked example: porting the AC pin wave to raw Android OpenGL ES 3.0

If you're embedding one of these into a plain `GLSurfaceView`-based Android app without any 3D engine, here is a minimal skeleton. It only covers **effect 2.3** (the 2D AC wave) because the spatial effects pay for themselves only with a 3D scene behind them.

**Fragment shader (`ac_wave.frag`, GLES 3.0):**

```glsl
#version 300 es
precision mediump float;

in  vec2 vUv;
out vec4 fragColor;

uniform float uTime;
uniform vec4  waveColor;      // sRGB, pre-multiplied-ish (alpha is used as weight)
uniform vec4  glowColor;
uniform float speed;
uniform float amplitude;
uniform float cycles;
uniform float lineThickness;
uniform float glowThickness;
uniform float softness;
uniform float horizontalPadding;
uniform float verticalCenterA;
uniform float verticalCenterB;

const float TAU = 6.2831853;

void main() {
    vec2 uv = vUv;
    float waveOffset = sin((uv.x - 0.5) * TAU * cycles - uTime * speed) * amplitude;
    float dA = abs(uv.y - (verticalCenterA + waveOffset));
    float dB = abs(uv.y - (verticalCenterB + waveOffset));

    float coreA = 1.0 - smoothstep(lineThickness, lineThickness + softness, dA);
    float coreB = 1.0 - smoothstep(lineThickness, lineThickness + softness, dB);
    float glowA = 1.0 - smoothstep(lineThickness, glowThickness, dA);
    float glowB = 1.0 - smoothstep(lineThickness, glowThickness, dB);

    float fadeL = smoothstep(horizontalPadding - softness, horizontalPadding + softness, uv.x);
    float fadeR = 1.0 - smoothstep(1.0 - horizontalPadding - softness, 1.0 - horizontalPadding + softness, uv.x);
    float hMask = fadeL * fadeR;

    float core = max(coreA, coreB) * hMask;
    float glow = max(glowA, glowB) * hMask;

    vec3 color = glowColor.rgb * glow * glowColor.a;
    color = mix(color, waveColor.rgb, core);
    float alpha = clamp(glow * glowColor.a + core * waveColor.a, 0.0, 1.0);
    if (alpha <= 0.001) discard;

    fragColor = vec4(color, alpha);
}
```

**Vertex shader (`ac_wave.vert`):**

```glsl
#version 300 es
in vec2 aPos;     // clip-space quad, -1..1
in vec2 aUv;      // 0..1
out vec2 vUv;
void main() {
    vUv = aUv;
    gl_Position = vec4(aPos, 0.0, 1.0);
}
```

**Kotlin host glue (sketch):**

```kotlin
class AcWaveRenderer : GLSurfaceView.Renderer {
    private var program = 0
    private var startMs = 0L

    override fun onSurfaceCreated(gl: GL10?, cfg: EGLConfig?) {
        program = linkProgram(readAsset("ac_wave.vert"), readAsset("ac_wave.frag"))
        startMs = SystemClock.elapsedRealtime()

        GLES30.glEnable(GLES30.GL_BLEND)
        GLES30.glBlendFunc(GLES30.GL_SRC_ALPHA, GLES30.GL_ONE_MINUS_SRC_ALPHA) // blend_mix
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT)
        GLES30.glUseProgram(program)

        val t = (SystemClock.elapsedRealtime() - startMs) / 1000f
        GLES30.glUniform1f(loc("uTime"), t)
        GLES30.glUniform4f(loc("waveColor"), 0.20f, 0.67f, 0.92f, 0.94f)
        GLES30.glUniform4f(loc("glowColor"), 0.53f, 0.88f, 1.00f, 0.30f)
        GLES30.glUniform1f(loc("speed"), 1.24f)
        GLES30.glUniform1f(loc("amplitude"), 0.054f)
        GLES30.glUniform1f(loc("cycles"), 1.28f)
        GLES30.glUniform1f(loc("lineThickness"), 0.024f)
        GLES30.glUniform1f(loc("glowThickness"), 0.068f)
        GLES30.glUniform1f(loc("softness"), 0.014f)
        GLES30.glUniform1f(loc("horizontalPadding"), 0.08f)
        GLES30.glUniform1f(loc("verticalCenterA"), 0.34f)
        GLES30.glUniform1f(loc("verticalCenterB"), 0.68f)

        drawFullscreenQuad()
    }

    private fun loc(name: String) = GLES30.glGetUniformLocation(program, name)
    override fun onSurfaceChanged(gl: GL10?, w: Int, h: Int) { GLES30.glViewport(0, 0, w, h) }
}
```

The same skeleton, with `render_mode blend_add` → `glBlendFunc(GL_SRC_ALPHA, GL_ONE)` and a `uniform float uCoreTemp` etc., covers the other effects — the only difference is that spatial effects need a real 3D pass with depth testing on and depth write off.

---

## 6. Android performance checklist

These shaders were tuned for mid-range Android GPUs (Adreno 6xx / Mali-G5x class). Keep these in mind when reusing them:

- **All are `precision mediump float`-safe.** No 32-bit math required on the fragment side. If your host pipeline defaults to highp, downgrade to mediump for these effects.
- **No texture samples.** Every effect is purely procedural, so there is no bandwidth cost beyond the framebuffer blend. Overdraw is the real cost — keep the meshes tight to the effect footprint.
- **Disable depth-write (`depth_draw_never` / `glDepthMask(false)`).** The spatial effects rely on it. Leaving it on causes the additive layers to occlude each other.
- **Use 2× MSAA max.** The reference app runs at 2×; anything higher burns power without visible gain on phone-sized screens.
- **Pulse uniforms are cheap.** The `sin(TIME * speed)` animation is a single ALU op; don't be tempted to drive it from the CPU.
- **Room size matters for heatmap / air-quality.** `room_extent` / `highlight_radius` must be in the same units as `VERTEX.xz` — if you pre-scale your meshes, scale the uniforms the same way, otherwise the gradient will bleed past the walls or collapse to a dot.
- **For the AC wave inside a `SubViewport`** on Android, keep the viewport at the pin's real pixel size (256×332 in the reference). Rendering the wave at higher resolution wastes fill rate — nothing in the shader benefits from it.

---

## 7. License & attribution

These shaders were hand-authored for this project. When copying them into a third-party Android app, keep a short credit somewhere in your acknowledgements (e.g. *"Effect shaders adapted from the SmartThings 3D Home reference app"*) and preserve the `.gdshader` source headers. The shader code is GLSL — not subject to any proprietary dependency — and can be translated/modified freely on your side.

---

## 8. Contact points in the reference code

When in doubt, read the real call-sites:

- Light glow + cloud wiring — [scripts/device_pin.gd:1058](scripts/device_pin.gd:1058)
- AC pin wave wiring — [scripts/device_pin.gd:401](scripts/device_pin.gd:401), [scripts/device_pin.gd:1016](scripts/device_pin.gd:1016)
- Temperature wash wiring — [scripts/device_pin.gd:514](scripts/device_pin.gd:514), [scripts/device_pin.gd:1122](scripts/device_pin.gd:1122)
- Air-quality tint wiring — [scripts/air_purifier.gd:144](scripts/air_purifier.gd:144), [scripts/air_purifier.gd:249](scripts/air_purifier.gd:249)

That's the whole surface area. Six shaders, one integration pattern (`ShaderMaterial` + `set_shader_parameter`), three deployment paths.
