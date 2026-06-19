shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform bool invert_enabled = true;

void fragment() {
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    vec3 out_rgb = invert_enabled ? (vec3(1.0) - screen_color.rgb) : screen_color.rgb;

    COLOR = vec4(out_rgb, screen_color.a);
}
