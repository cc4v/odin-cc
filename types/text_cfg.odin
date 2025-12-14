package types

TextCfg :: struct {
	color: Color,
    size: int
}

default_textcfg :: proc() -> TextCfg {
    return TextCfg {
        color = default_color(),
        size = 16
    }
}