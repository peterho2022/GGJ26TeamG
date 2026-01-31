shader_type canvas_item;

uniform sampler2D mask_tex : source_color;
uniform vec4 layer_color : source_color = vec4(1.0, 0.2, 0.2, 1.0);

void fragment() {
    float m = texture(mask_tex, UV).r; // 白=膠帶
    float a = 1.0 - m;                 // 沒遮到才上色
    COLOR = layer_color;
    COLOR.a *= ceil(a);
}
