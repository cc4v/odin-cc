package types

Color :: struct {
	r: u8,
    g: u8,
    b: u8,
    a: u8
}

color :: proc "contextless" (r: u8, g: u8, b: u8, a :u8 = 255) -> Color {
    return Color {
        r = r,
        g = g,
        b = b,
        a = a
    }
}