shader_type canvas_item;
uniform float skew_factor : hint_range(-1.0, 1.0);
void vertex() {
   VERTEX.x += VERTEX.y * skew_factor; // Skew along the X-axis
}