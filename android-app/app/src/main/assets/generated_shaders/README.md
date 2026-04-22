# Android Shader Pack

Generated from the CSV parameter inventory with Godot 4 compatible shader code.
Several close variants are intentionally merged onto a parent shader file to keep the pack maintainable and Android-friendly.

## Logical Shader Mapping

- `SpriteOpaque` -> `sprite_opaque.gdshader`
- `WallDepthShader` -> `wall_depth_shader.gdshader`
- `Simple Lit Overlay` -> `simple_lit_overlay.gdshader`
- `SpriteOpaqueIcon` -> `sprite_opaque_icon.gdshader`
- `SpriteColorShadow` -> `sprite_color_shadow.gdshader`
- `Heatmap H Base Stenciled` -> `heatmap_base.gdshader`
- `Heatmap H Cover Stenciled` -> `heatmap_cover.gdshader`
- `Heatmap Unlit 3D` -> `heatmap_unlit_3d.gdshader`
- `Heatmap Unlit 3D H Base` -> `heatmap_base.gdshader`
- `Heatmap Unlit 3D H Cover` -> `heatmap_cover.gdshader`
- `Heatmap Base` -> `heatmap_unlit_3d.gdshader`
- `TMP_SDF-Mobile` -> `tmp_sdf_mobile.gdshader`
- `TMP_SDF-Mobile-2-Pass-Outline` -> `tmp_sdf_mobile_outline.gdshader`
- `TMP_SDF-Mobile-2-Pass-Face` -> `tmp_sdf_mobile_face.gdshader`
- `two_tone_color_unlit` -> `two_tone_color_unlit.gdshader`
- `two_tone_transparent_color_unlit` -> `two_tone_transparent_color_unlit.gdshader`
- `two_tone_color_unlit_opacity` -> `two_tone_color_unlit_opacity.gdshader`
- `house_texture_lit` -> `house_texture_lit.gdshader`
- `house_texture_unlit` -> `house_texture_unlit.gdshader`
- `shadow_catcher` -> `shadow_catcher.gdshader`
- `triplanar_lit` -> `triplanar_lit.gdshader`
- `divider` -> `divider.gdshader`
- `edit_mode_grid` -> `edit_mode_grid.gdshader`
- `sprite_color` -> `sprite_color.gdshader`
- `wall_render_outer` -> `wall_render_outer.gdshader`
- `character_lit` -> `character_lit.gdshader`
- `two_layered_lit` -> `two_layered_lit.gdshader`
- `block_3d` -> `block_3d.gdshader`
- `device_progress` -> `device_progress.gdshader`
- `sprite_color_zwrite` -> `sprite_color.gdshader`
- `sprite_icon_unlit` -> `sprite_icon_unlit.gdshader`
- `heatmap_box_stenciled` -> `heatmap_unlit_3d.gdshader`
- `wall_render_outer_side` -> `wall_render_outer_side.gdshader`
- `floor_pattern` -> `floor_pattern.gdshader`
- `furniture_two_tone_lit` -> `furniture_two_tone_lit.gdshader`

## Regeneration

Run `python3 tools/generate_android_shader_pack.py` from the repository root.
