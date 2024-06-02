shader_type spatial;
render_mode unshaded;

uniform sampler2D texture : source_color;
uniform bool lock_aspect = false;
uniform float aspect_ratio = 1.3333333;
uniform vec2 fov = vec2(180.0, 90.0);
uniform ivec2 tiling = ivec2(1, 1);
uniform vec2 offset = vec2(0.0, 0.0);

varying vec2 BG_COORDS;
varying vec2 BG_SCALE;

vec4 n64BilinearFilter(vec2 texcoord) {
	ivec2 tex_size = textureSize(texture, 0);
	float Texture_X = float(tex_size.x) * 4.0;
	float Texture_Y = float(tex_size.y) * 4.0;

	vec2 tex_pix_a = vec2(1.0/Texture_X,0.0);
	vec2 tex_pix_b = vec2(0.0,1.0/Texture_Y);
	vec2 tex_pix_c = vec2(tex_pix_a.x,tex_pix_b.y);
	vec2 half_tex = vec2(tex_pix_a.x*0.5,tex_pix_b.y*0.5);
	vec2 UVCentered = texcoord - half_tex;

	vec4 diffuseColor = texture(texture,UVCentered);
	vec4 sample_a = texture(texture,UVCentered+tex_pix_a);
	vec4 sample_b = texture(texture,UVCentered+tex_pix_b);
	vec4 sample_c = texture(texture,UVCentered+tex_pix_c);

	float interp_x = modf(UVCentered.x * Texture_X, Texture_X);
	float interp_y = modf(UVCentered.y * Texture_Y, Texture_Y);

	if (UVCentered.x < 0.0)
	{
		interp_x = 1.0-interp_x*(-1.0);
	}
	if (UVCentered.y < 0.0)
	{
		interp_y = 1.0-interp_y*(-1.0);
	}

	diffuseColor = (diffuseColor + interp_x * (sample_a - diffuseColor) + interp_y * (sample_b - diffuseColor))*(1.0-step(1.0, interp_x + interp_y));
	diffuseColor += (sample_c + (1.0-interp_x) * (sample_b - sample_c) + (1.0-interp_y) * (sample_a - sample_c))*step(1.0, interp_x + interp_y);

    return diffuseColor;
}

void vertex() {
	//Camera YX rotation per Basis.get_euler source code
	float y = atan(VIEW_MATRIX[0][2], VIEW_MATRIX[2][2]);
	float x = asin(VIEW_MATRIX[1][2]);
	
	//Map rotation to screen space
	BG_COORDS = vec2(y * 0.5, -x) * -(1.0 / PI);
	BG_COORDS.y += 0.5;
	
	BG_SCALE.y = fov.y * (1.0 / 180.0);
	BG_SCALE.x = !lock_aspect ? 
		fov.x * (1.0 / 360.0) : 
		VIEWPORT_SIZE.x / (VIEWPORT_SIZE.y * aspect_ratio) * BG_SCALE.y;
	
	//Keep background centered vertically when FOV changes
	BG_COORDS.y *= BG_SCALE.y > 1.0 ? 0.0 : 1.0 - BG_SCALE.y;
}

void fragment() {
	vec2 uv_offset = vec2(-offset.x, offset.y);
	vec2 uv = (SCREEN_UV + uv_offset) * BG_SCALE + BG_COORDS;
	vec4 color = n64BilinearFilter(uv);
	uv *= vec2(tiling);
	ALBEDO = color.rgb;
}