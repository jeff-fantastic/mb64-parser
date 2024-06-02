render_mode LIT, CULL, shadows_disabled, specular_disabled, DEPTH, BLEND;

uniform vec4 modulate_color : source_color = vec4(1.0);

#ifndef NO_TEXTURE
uniform sampler2D albedoTex : source_color, filter_nearest, repeat_enable;
#endif

#ifdef TEXTURE_ARRAY
uniform sampler2DArray albedoArray : source_color, filter_nearest, repeat_enable;
uniform int frames = 0;
uniform bool pingpong = false;
#endif

uniform bool filter = true;

#if (!defined(NO_TEXTURE) || defined(TEXTURE_ARRAY)) && !defined(METAL)  // METAL doesn't use UV, so no need for panning properties
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
uniform vec2 uv_pan_velocity = vec2(0.0);
#endif

#ifdef N64LIT
uniform bool cull_flag = true; // Identifier
#endif

#ifdef N64TRANSPARENT
uniform bool transparent_flag = true; // Identifier
#endif

#ifdef ALPHA_SCISSOR
uniform bool billboard = false;
uniform bool y_billboard = false;
uniform float alpha_scissor : hint_range(0, 1) = 0.1;
#endif

// https://www.emutalk.net/threads/emulating-nintendo-64-3-sample-bilinear-filtering-using-shaders.54215/
#ifndef NO_TEXTURE
vec4 n64BilinearFilter(vec4 vtx_color, vec2 texcoord) {
	ivec2 tex_size = textureSize(albedoTex, 0);
	float Texture_X = float(tex_size.x);
	float Texture_Y = float(tex_size.y);

	vec2 tex_pix_a = vec2(1.0/Texture_X,0.0);
	vec2 tex_pix_b = vec2(0.0,1.0/Texture_Y);
	vec2 tex_pix_c = vec2(tex_pix_a.x,tex_pix_b.y);
	vec2 half_tex = vec2(tex_pix_a.x*0.5,tex_pix_b.y*0.5);
	vec2 UVCentered = texcoord - half_tex;

	vec4 diffuseColor = texture(albedoTex,UVCentered);
	vec4 sample_a = texture(albedoTex,UVCentered+tex_pix_a);
	vec4 sample_b = texture(albedoTex,UVCentered+tex_pix_b);
	vec4 sample_c = texture(albedoTex,UVCentered+tex_pix_c);

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

    return diffuseColor * vtx_color;
}
#endif

void vertex()
{
#if !defined(NO_TEXTURE) && !defined(METAL)  // METAL doesn't use UV, so no need to pan UVs
	UV = UV * uv_scale + uv_offset;
	vec2 to_pan = uv_pan_velocity * TIME;
	if (!filter) {
		to_pan = (uv_pan_velocity / 32.0) * round(TIME * 2.5);
	}
	UV += to_pan;
#endif

#ifdef ALPHA_SCISSOR
	if (y_billboard)
	{
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],MODEL_MATRIX[1],vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz,MODEL_MATRIX[1].xyz)), 0.0),MODEL_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(1.0, 0.0, 0.0, 0.0),vec4(0.0, 1.0/length(MODEL_MATRIX[1].xyz), 0.0, 0.0), vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0 ,1.0));
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
		MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0.0, 0.0, 0.0),vec4(0.0, length(MODEL_MATRIX[1].xyz), 0.0, 0.0),vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz), 0.0),vec4(0.0, 0.0, 0.0, 1.0));
	}
	else if (billboard)
	{
		mat4 mat_world = mat4(normalize(INV_VIEW_MATRIX[0])*length(MODEL_MATRIX[0]),normalize(INV_VIEW_MATRIX[1])*length(MODEL_MATRIX[0]),normalize(INV_VIEW_MATRIX[2])*length(MODEL_MATRIX[2]),MODEL_MATRIX[3]);
		// MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
		mat_world *= mat4( vec4(cos(INSTANCE_CUSTOM.x),-sin(INSTANCE_CUSTOM.x), 0.0, 0.0), vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),vec4(0.0, 0.0, 1.0, 0.0),vec4(0.0, 0.0, 0.0, 1.0));
		MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;
	}
#endif
}

void fragment()
{
#ifdef METAL
	vec2 texture_uv = vec2(NORMAL.x / 2.0 + 0.5, (-NORMAL.y) / 2.0 + 0.5);  // Special thanks to Adam McLaughlan
#elif (!defined(NO_TEXTURE) || defined(TEXTURE_ARRAY))
	vec2 texture_uv = UV;
#endif

	vec4 color_base = COLOR * modulate_color;

#ifdef TEXTURE_ARRAY
	vec4 texture_color;
	float frame;
	if (pingpong) {
		// If you see this shader code... you didnt, actually
		frame = float(int((uv_pan_velocity.y / 100.0) * (TIME * 100.0)) % (frames * 2));
		frame = (int(floor(frame)) >= frames) ? float(frames - 1) - float(int(floor(frame)) % frames) : floor(frame);
	} else {
		frame = floor(float(int((uv_pan_velocity.y / 100.0) * (TIME * 100.0)) % frames));
	}
	texture_color = texture(albedoArray, vec3(texture_uv.x, texture_uv.y, frame));
	ALBEDO = (color_base * texture_color).rgb;
#elif defined(NO_TEXTURE)
	ALBEDO = color_base.rgb;
#else
	vec4 texture_color;
	if (filter) {
		texture_color = n64BilinearFilter(COLOR, texture_uv);
	} else {
		texture_color = texture(albedoTex, texture_uv);
	}
	
	ALBEDO = (color_base * texture_color).rgb;
#endif

#if defined(ALPHA_BLEND) || defined(ALPHA_SCISSOR)
	ALPHA = texture_color.a * color_base.a;
#endif

#ifdef ALPHA_SCISSOR
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor;
#endif
}
