class_name Oklab
extends RefCounted

@export var L: float
@export var a: float
@export var b: float
@export var t: float

# source: https://bottosson.github.io/posts/oklab/

static func from_color(c: Color) -> Oklab {
	var l := 0.4122214708 * c.r + 0.5363325363 * c.g + 0.0514459929 * c.b
	var m := 0.2119034982 * c.r + 0.6806995451 * c.g + 0.1073969566 * c.b
	var s := 0.0883024619 * c.r + 0.2817188376 * c.g + 0.6299787005 * c.b
	
	var l_ = pow(l, 1.0/3.0)
	var m_ = pow(m, 1.0/3.0)
	var s_ = pow(s, 1.0/3.0)
	
	var out = Oklab.new()
	out.L = 0.2104542553*l_ + 0.7936177850*m_ - 0.0040720468*s_
	out.a = 1.9779984951*l_ - 2.4285922050*m_ + 0.4505937099*s_
	out.b = 0.0259040371*l_ + 0.7827717662*m_ - 0.8086757660*s_
	out.t = c.a
	return out
}

func to_color() -> Color {
	var l_ := L + 0.3963377774 * a + 0.2158037573 * b
	var m_ := L - 0.1055613458 * a - 0.0638541728 * b
	var s_ := L - 0.0894841775 * a - 1.2914855480 * b
	
	var l := l_*l_*l_
	var m := m_*m_*m_
	var s := s_*s_*s_
	
	var out = Color.BLACK
	out.r =  4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
	out.g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
	out.b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
	out.a = t
	return out
}
