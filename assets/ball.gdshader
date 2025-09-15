shader_type canvas_item;

uniform float rate = 0.125;

void vertex() {
	float pi = 3.141592653589793;
	float a = fract(TIME * rate) * pi * 2.;
	VERTEX = mat2(vec2(cos(a), sin(a)), vec2(-sin(a), cos(a))) * VERTEX;
}