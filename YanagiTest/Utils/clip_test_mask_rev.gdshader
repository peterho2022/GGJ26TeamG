shader_type canvas_item;

uniform vec4 albedo = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D base_tex;
uniform sampler2D mask_tex; // ← ViewportTexture

void fragment() {
    vec4 base = texture(base_tex, UV) * albedo;
    float m = texture(mask_tex, UV).a; // alpha 當 mask
    base.a = m;
    COLOR = base;
}
