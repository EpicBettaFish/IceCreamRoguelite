shader_type canvas_item;

uniform float opacity = 1;

void fragment() {
	vec4 pixelColor = texture(TEXTURE, UV);
	if (pixelColor.r == 1.0) {
		pixelColor.a = 0.0;
	}
	else {
		pixelColor.r = 1.0;
		pixelColor.g = 1.0;
		pixelColor.b = 1.0;
		pixelColor.a = opacity;
	}
	COLOR = pixelColor;
}