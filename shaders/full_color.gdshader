shader_type canvas_item;

uniform vec3 color: source_color = vec3(1.0);
uniform bool active = false;

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	if (active) {original.rgb = color;}
	COLOR = original;
}
