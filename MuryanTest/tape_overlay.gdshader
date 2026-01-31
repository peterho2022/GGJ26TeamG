shader_type canvas_item;

uniform sampler2D mask_tex : source_color;
uniform vec4 tape_color : source_color = vec4(1.0, 0.92, 0.55, 1.0);
uniform float tape_opacity = 1.0;

void fragment() {
    float m = texture(mask_tex, UV).r; // 白=膠帶
    COLOR = tape_color;
    COLOR.a *= m * tape_opacity;       // 只在膠帶區域顯示
}
