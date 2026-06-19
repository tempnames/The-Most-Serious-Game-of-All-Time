shader_type canvas_item;

uniform float diamond_size : hint_range(0.0, 1.0) = 0.3;          // Diamond size (relative to UV space)
uniform float diamond_width : hint_range(0.01, 0.2) = 0.05;       // Border thickness
uniform vec3 diamond_color : source_color = vec3(0.6, 0.8, 0.9);  // Diamond color
uniform float diamond_fade : hint_range(0.0, 1.0) = 1.0;          // Visibility fade (0=hidden, 1=full)
uniform float diamond_countdown : hint_range(0.0, 1.0) = 1.0;     // 1=complete, 0=disappeared clockwise from top

void fragment() {
    // Map UV to [-1,1]
    vec2 uv = UV * 2.0 - 1.0;
    
    //==============================
    // ① Diamond Shape (Manhattan Distance)
    //==============================
    // For a diamond, use Manhattan distance (|x| + |y|)
    float manhattan_dist = abs(uv.x) + abs(uv.y);
    
    // Create diamond outline
    float diamond_shape = smoothstep(diamond_size - diamond_width, diamond_size, manhattan_dist)
                        - smoothstep(diamond_size, diamond_size + diamond_width, manhattan_dist);
    diamond_shape *= diamond_fade;
    
    //==============================
    // ② Clockwise countdown from top
    //==============================
    // Calculate angle (top = 0, clockwise increases)
    float angle = atan(uv.x, -uv.y);      // Top at 0, clockwise positive
    angle = mod(angle, 6.2831853);        // [0, 2π]
    angle /= 6.2831853;                   // Map to [0,1]
    
    float countdown_mask = step(angle, diamond_countdown);
    
    //==============================
    // ③ Final Diamond
    //==============================
    float diamond_value = diamond_shape * countdown_mask;
    vec3 color = diamond_color * diamond_value;
    float alpha = max(max(color.r, color.g), color.b);
    
    COLOR = vec4(color, alpha);
}