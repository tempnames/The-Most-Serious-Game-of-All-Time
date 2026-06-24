class_name Glyph extends RichTextLabel

static func from_char(p_char: String) -> Glyph {
	assert(p_char.length() == 1, "That isn't a char it's an entire string!!!")
	var g := Registry.create_glyph()
	g.text = p_char
	return g
}

func set_font_size(new_size: int) -> Glyph {
	self.add_theme_font_size_override(&"font_size", new_size)
	return self
}
