shader_type canvas_item;

uniform vec4 color_gap : source_color = vec4(0.25, 0.25, 0.25, 1.0);
uniform vec4 color_stripe : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float divisions = 8.0;
uniform float stripe_bias = 2.5;
uniform float speed = 0.1;
uniform float angle = 0.785398;

uniform float border_width : hint_range(0.0, 0.5) = 0.05;
uniform float skew = 0.0;

void vertex() {
	VERTEX.x += VERTEX.y * skew;
}

void fragment() {
	// Distance to nearest edge in UV space
	float edge_dist = min(
		min(UV.x, 1.0 - UV.x),
		min(UV.y, 1.0 - UV.y)
	);

	// Border mask: 1.0 on border, 0.0 inside
	float border_mask = step(edge_dist, border_width);

	// Stripe coordinate
	float w = cos(angle) * UV.x + sin(angle) * UV.y - speed * TIME;
	float stripe = floor(mod(w * divisions, stripe_bias));

	vec4 stripe_color = (stripe < 0.0001) ? color_gap : color_stripe;

	// Apply border mask
	COLOR = stripe_color * border_mask;
}
