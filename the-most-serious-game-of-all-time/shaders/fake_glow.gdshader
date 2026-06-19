shader_type canvas_item;

// Screen texture sampler
uniform sampler2D screen_texture : hint_screen_texture, filter_linear, repeat_disable;

// Glow parameters
uniform float glow_intensity : hint_range(0.0, 5.0, 0.1) = 1.5;
uniform float glow_threshold : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float blur_size : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform int blur_samples : hint_range(4, 32, 1) = 16;

// Optional tint
uniform vec4 glow_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

render_mode blend_add;

void fragment() {
	vec2 pixel_size = 1.0 / vec2(textureSize(screen_texture, 0));
	
	// Sample the original pixel
	vec4 original = texture(screen_texture, SCREEN_UV);
	
	// Check if pixel is above threshold (bright enough to glow)
	vec4 bright_pixel = vec4(0.0);
	if (original.r > glow_threshold || original.g > glow_threshold || original.b > glow_threshold) {
		bright_pixel = original;
	}
	
	// Blur the bright pixels
	vec4 blurred = vec4(0.0);
	float total_weight = 0.0;
	
	// Circular blur pattern
	float angle_step = 6.28318 / float(blur_samples); // 2*PI / samples
	
	for (int i = 0; i < blur_samples; i++) {
		float angle = float(i) * angle_step;
		vec2 offset = vec2(cos(angle), sin(angle)) * blur_size * pixel_size;
		
		vec4 sample_color = texture(screen_texture, SCREEN_UV + offset);
		
		// Only blur bright pixels
		if (sample_color.r > glow_threshold || sample_color.g > glow_threshold || sample_color.b > glow_threshold) {
			float weight = 1.0;
			blurred += sample_color * weight;
			total_weight += weight;
		}
	}
	
	// Add inner samples for better quality
	for (int i = 0; i < blur_samples / 2; i++) {
		float angle = float(i) * angle_step * 2.0;
		vec2 offset = vec2(cos(angle), sin(angle)) * blur_size * 0.5 * pixel_size;
		
		vec4 sample_color = texture(screen_texture, SCREEN_UV + offset);
		
		if (sample_color.r > glow_threshold || sample_color.g > glow_threshold || sample_color.b > glow_threshold) {
			float weight = 1.5;
			blurred += sample_color * weight;
			total_weight += weight;
		}
	}
	
	if (total_weight > 0.0) {
		blurred /= total_weight;
	}
	
	// Apply glow intensity and tint
	vec4 glow = blurred * glow_intensity * glow_tint;
	
	// Output the glow (render_mode blend_add will add it to the scene)
	COLOR = glow;
}