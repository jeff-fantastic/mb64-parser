shader_type spatial;

#define LIT diffuse_lambert, vertex_lighting
#define DEPTH depth_draw_opaque
#define BLEND blend_mix
#define CULL cull_back
#define ALPHA_BLEND

#include "n64_base.gdshaderinc"
