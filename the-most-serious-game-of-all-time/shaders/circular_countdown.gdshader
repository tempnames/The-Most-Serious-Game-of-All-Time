shader_type canvas_item;

uniform float ring_radius : hint_range(0.0, 1.0) = 0.3;           // 圆环半径（相对于UV[-1,1]空间）
uniform float ring_width : hint_range(0.01, 0.2) = 0.05;          // 圆环厚度
uniform vec3 ring_color : source_color = vec3(0.6, 0.8, 0.9);     // 圆环颜色
uniform float ring_fade : hint_range(0.0, 1.0) = 1.0;             // 显隐渐变（0=隐藏，1=全显）
uniform float ring_countdown : hint_range(0.0, 1.0) = 1.0;        // 1=完整，0=从12点顺时针完全消失



void fragment() {

    // 映射 UV 到 [-1,1]

    vec2 uv = UV * 2.0 - 1.0;

    float dis = length(uv);



    //==============================

    // ① 基础圆环形状

    //==============================

    float ring_shape = smoothstep(ring_radius - ring_width, ring_radius, dis)

                     - smoothstep(ring_radius, ring_radius + ring_width, dis);

    ring_shape *= ring_fade;



    //==============================

    // ② 从 12 点方向开始顺时针逐渐消失

    //==============================

    float angle = atan(-uv.x, -uv.y);     // 12点为0，顺时针递增

    angle = mod(angle, 6.2831853);        // [0, 2π]

    angle /= 6.2831853;                   // 映射到 [0,1]

    float countdown_mask = step(angle, ring_countdown);



    //==============================

    // ③ 最终圆环

    //==============================

    float ring_value = ring_shape * countdown_mask;

    vec3 color = ring_color * ring_value;

    float alpha = max(max(color.r, color.g), color.b);

    COLOR = vec4(color, alpha);

}

