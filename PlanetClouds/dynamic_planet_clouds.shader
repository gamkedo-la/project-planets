shader_type spatial;
render_mode blend_mix,cull_back,diffuse_burley,specular_schlick_ggx
,depth_draw_alpha_prepass
;
uniform vec3 uv1_offset = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 16;
uniform vec2 depth_flip = vec2(1.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}

vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}

vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}

float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


float fbm_value(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float p00 = rand(mod(o, size));
	float p01 = rand(mod(o + vec2(0.0, 1.0), size));
	float p10 = rand(mod(o + vec2(1.0, 0.0), size));
	float p11 = rand(mod(o + vec2(1.0, 1.0), size));
	p00 = sin(p00 * 6.28318530718 + offset) / 2.0 + 0.5;
	p01 = sin(p01 * 6.28318530718 + offset) / 2.0 + 0.5;
	p10 = sin(p10 * 6.28318530718 + offset) / 2.0 + 0.5;
	p11 = sin(p11 * 6.28318530718 + offset) / 2.0 + 0.5;
	vec2 t =  f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return mix(mix(p00, p10, t.x), mix(p01, p11, t.x), t.y);
}

float fbm_perlin(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float a00 = rand(mod(o, size)) * 6.28318530718 + offset;
	float a01 = rand(mod(o + vec2(0.0, 1.0), size)) * 6.28318530718 + offset;
	float a10 = rand(mod(o + vec2(1.0, 0.0), size)) * 6.28318530718 + offset;
	float a11 = rand(mod(o + vec2(1.0, 1.0), size)) * 6.28318530718 + offset;
	vec2 v00 = vec2(cos(a00), sin(a00));
	vec2 v01 = vec2(cos(a01), sin(a01));
	vec2 v10 = vec2(cos(a10), sin(a10));
	vec2 v11 = vec2(cos(a11), sin(a11));
	float p00 = dot(v00, f);
	float p01 = dot(v01, f - vec2(0.0, 1.0));
	float p10 = dot(v10, f - vec2(1.0, 0.0));
	float p11 = dot(v11, f - vec2(1.0, 1.0));
	vec2 t =  f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return 0.5 + mix(mix(p00, p10, t.x), mix(p01, p11, t.x), t.y);
}

float fbm_perlinabs(vec2 coord, vec2 size, float offset, float seed) {
	return abs(2.0*fbm_perlin(coord, size, offset, seed)-1.0);
}

float mod289(float x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float permute(float x) {
    return mod289(((x * 34.0) + 1.0) * x);
}

vec2 rgrad2(vec2 p, float rot, float seed) {
	float u = permute(permute(p.x) + p.y) * 0.0243902439 + rot; // Rotate by shift
	u = fract(u) * 6.28318530718; // 2*pi
	return vec2(cos(u), sin(u));
}

float fbm_simplex(vec2 coord, vec2 size, float offset, float seed) {
	coord *= 2.0; // needed for it to tile
	coord += rand2(vec2(seed, 1.0-seed)) + size;
	size *= 2.0; // needed for it to tile
	coord.y += 0.001;
    vec2 uv = vec2(coord.x + coord.y*0.5, coord.y);
    vec2 i0 = floor(uv);
    vec2 f0 = fract(uv);
    vec2 i1 = (f0.x > f0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec2 p0 = vec2(i0.x - i0.y * 0.5, i0.y);
    vec2 p1 = vec2(p0.x + i1.x - i1.y * 0.5, p0.y + i1.y);
    vec2 p2 = vec2(p0.x + 0.5, p0.y + 1.0);
    i1 = i0 + i1;
    vec2 i2 = i0 + vec2(1.0, 1.0);
    vec2 d0 = coord - p0;
    vec2 d1 = coord - p1;
    vec2 d2 = coord - p2;
    vec3 xw = mod(vec3(p0.x, p1.x, p2.x), size.x);
    vec3 yw = mod(vec3(p0.y, p1.y, p2.y), size.y);
    vec3 iuw = xw + 0.5 * yw;
    vec3 ivw = yw;
    vec2 g0 = rgrad2(vec2(iuw.x, ivw.x), offset, seed);
    vec2 g1 = rgrad2(vec2(iuw.y, ivw.y), offset, seed);
    vec2 g2 = rgrad2(vec2(iuw.z, ivw.z), offset, seed);
    vec3 w = vec3(dot(g0, d0), dot(g1, d1), dot(g2, d2));
    vec3 t = 0.8 - vec3(dot(d0, d0), dot(d1, d1), dot(d2, d2));
    t = max(t, vec3(0.0));
    vec3 t2 = t * t;
    vec3 t4 = t2 * t2;
    float n = dot(t4, w);
    return 0.5 + 5.5 * n;
}

float fbm_cellular(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node =  0.5 + 0.25 * sin(offset + 6.2831 * node);
			vec2 diff = neighbor + node - f;
			float dist = length(diff);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}

float fbm_cellular2(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset + 6.2831*node);
			vec2 diff = neighbor + node - f;
			float dist = length(diff);
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}

float fbm_cellular3(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset + 6.2831*node);
			vec2 diff = neighbor + node - f;
			float dist = abs((diff).x) + abs((diff).y);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}

float fbm_cellular4(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset + 6.2831*node);
			vec2 diff = neighbor + node - f;
			float dist = abs((diff).x) + abs((diff).y);
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}

float fbm_cellular5(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.5 * sin(offset + 6.2831*node);
			vec2 diff = neighbor + node - f;
			float dist = max(abs((diff).x), abs((diff).y));
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}

float fbm_cellular6(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset + 6.2831*node);
			vec2 diff = neighbor + node - f;
			float dist = max(abs((diff).x), abs((diff).y));
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}

// MIT License Inigo Quilez - https://www.shadertoy.com/view/Xd23Dh
float fbm_voronoise( vec2 coord, vec2 size, float offset, float seed) {
    vec2 i = floor(coord) + rand2(vec2(seed, 1.0-seed)) + size;
    vec2 f = fract(coord);
    
	vec2 a = vec2(0.0);
	
    for( int y=-2; y<=2; y++ ) {
    	for( int x=-2; x<=2; x++ ) {
        	vec2  g = vec2( float(x), float(y) );
			vec3  o = rand3( mod(i + g, size) + vec2(seed) );
			o.xy += 0.25 * sin(offset + 6.2831*o.xy);
			vec2  d = g - f + o.xy;
			float w = pow( 1.0-smoothstep(0.0, 1.414, length(d)), 1.0 );
			a += vec2(o.z*w,w);
		}
    }
	
    return a.x/a.y;
}
vec2 transform2_clamp(vec2 uv) {
	return clamp(uv, vec2(0.0), vec2(1.0));
}

vec2 transform2(vec2 uv, vec2 translate, float rotate, vec2 scale) {
 	vec2 rv;
	uv -= translate;
	uv -= vec2(0.5);
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	rv /= scale;
	rv += vec2(0.5);
	return rv;	
}
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}

vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}

vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}

vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}

float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}

vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}

vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}

float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}

vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}

float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}

vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}

float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}

vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}

vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}

vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}

vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}

float shape_circle(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float distance = length(uv);
    return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}

float shape_polygon(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float angle = atan(uv.x, uv.y)+3.14159265359;
    float slice = 6.28318530718/sides;
    return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}

float shape_star(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float angle = atan(uv.x, uv.y);
    float slice = 6.28318530718/sides;
    return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}

float shape_curved_star(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
    float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
    float slice = 6.28318530718/sides;
    return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}

float shape_rays(vec2 uv, float sides, float size, float edge) {
    uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
    float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
    return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}


const float p_o8456_albedo_color_r = 1.000000000;
const float p_o8456_albedo_color_g = 1.000000000;
const float p_o8456_albedo_color_b = 1.000000000;
const float p_o8456_albedo_color_a = 1.000000000;
const float p_o8456_metallic = 0.000000000;
const float p_o8456_roughness = 1.000000000;
const float p_o8456_emission_energy = 1.000000000;
const float p_o8456_normal = 1.000000000;
const float p_o8456_ao = 1.000000000;
const float p_o8456_depth_scale = 0.500000000;
float o8456_input_depth_tex(vec2 uv, float _seed_variation_) {

return 0.0;
}
const float p_o428250_gradient_0_pos = 0.000000000;
const float p_o428250_gradient_0_r = 0.000000000;
const float p_o428250_gradient_0_g = 0.000000000;
const float p_o428250_gradient_0_b = 0.000000000;
const float p_o428250_gradient_0_a = 0.000000000;
const float p_o428250_gradient_1_pos = 0.227272727;
const float p_o428250_gradient_1_r = 0.372549027;
const float p_o428250_gradient_1_g = 0.341176480;
const float p_o428250_gradient_1_b = 0.309803933;
const float p_o428250_gradient_1_a = 0.356862754;
const float p_o428250_gradient_2_pos = 0.381818182;
const float p_o428250_gradient_2_r = 0.760784328;
const float p_o428250_gradient_2_g = 0.764705896;
const float p_o428250_gradient_2_b = 0.780392170;
const float p_o428250_gradient_2_a = 0.764705896;
const float p_o428250_gradient_3_pos = 1.000000000;
const float p_o428250_gradient_3_r = 1.000000000;
const float p_o428250_gradient_3_g = 0.945098042;
const float p_o428250_gradient_3_b = 0.909803927;
const float p_o428250_gradient_3_a = 0.925490201;
vec4 o428250_gradient_gradient_fct(float x) {
  if (x < p_o428250_gradient_0_pos) {
    return vec4(p_o428250_gradient_0_r,p_o428250_gradient_0_g,p_o428250_gradient_0_b,p_o428250_gradient_0_a);
  } else if (x < p_o428250_gradient_1_pos) {
    return mix(vec4(p_o428250_gradient_0_r,p_o428250_gradient_0_g,p_o428250_gradient_0_b,p_o428250_gradient_0_a), vec4(p_o428250_gradient_1_r,p_o428250_gradient_1_g,p_o428250_gradient_1_b,p_o428250_gradient_1_a), ((x-p_o428250_gradient_0_pos)/(p_o428250_gradient_1_pos-p_o428250_gradient_0_pos)));
  } else if (x < p_o428250_gradient_2_pos) {
    return mix(vec4(p_o428250_gradient_1_r,p_o428250_gradient_1_g,p_o428250_gradient_1_b,p_o428250_gradient_1_a), vec4(p_o428250_gradient_2_r,p_o428250_gradient_2_g,p_o428250_gradient_2_b,p_o428250_gradient_2_a), ((x-p_o428250_gradient_1_pos)/(p_o428250_gradient_2_pos-p_o428250_gradient_1_pos)));
  } else if (x < p_o428250_gradient_3_pos) {
    return mix(vec4(p_o428250_gradient_2_r,p_o428250_gradient_2_g,p_o428250_gradient_2_b,p_o428250_gradient_2_a), vec4(p_o428250_gradient_3_r,p_o428250_gradient_3_g,p_o428250_gradient_3_b,p_o428250_gradient_3_a), ((x-p_o428250_gradient_2_pos)/(p_o428250_gradient_3_pos-p_o428250_gradient_2_pos)));
  }
  return vec4(p_o428250_gradient_3_r,p_o428250_gradient_3_g,p_o428250_gradient_3_b,p_o428250_gradient_3_a);
}
const float p_o8469_amount = 1.000000000;
const float p_o8461_x = 300.000000000;
const float p_o8461_y = 300.000000000;
const float p_o8461_c = 7.000000000;
const float p_o8461_d = 0.180000000;
const float p_o8467_amount = 0.410000000;
const float seed_o8463 = 0.000000000;
const float p_o8463_scale_x = 13.000000000;
const float p_o8463_scale_y = 17.000000000;
const float p_o8463_folds = 0.000000000;
const float p_o8463_iterations = 1.000000000;
const float p_o8463_persistence = 0.500000000;
const float p_o8463_offset = 0.000000000;
float o8463_fbm(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed, float _seed_variation_) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = fbm_voronoise(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
const float p_o8462_default_in2 = 1.000000000;
const float p_o50932_translate_y = 0.000000000;
const float p_o50932_rotate = 0.000000000;
const float p_o50932_scale_x = 1.000000000;
const float p_o50932_scale_y = 1.000000000;
const float seed_o8457 = 0.000000000;
const float p_o8457_scale_x = 4.000000000;
const float p_o8457_scale_y = 27.000000000;
const float p_o8457_folds = 0.000000000;
const float p_o8457_iterations = 5.000000000;
const float p_o8457_persistence = 0.500000000;
const float p_o8457_offset = 0.000000000;
float o8457_fbm(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed, float _seed_variation_) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = fbm_voronoise(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
const float p_o24085_x = 300.000000000;
const float p_o24085_y = 300.000000000;
const float p_o24085_c = 2.000000000;
const float p_o24085_d = 0.000000000;
const float p_o8468_sides = 2.000000000;
const float p_o8468_radius = 0.900000000;
const float p_o8468_edge = 0.000000000;


void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
vec2 o8461_0_uv = floor(((uv)*vec2(p_o8461_x, p_o8461_y)))+vec2(0.5);
vec3 o8461_0_dither = fract(vec3(dot(vec2(171.0, 231.0), o8461_0_uv))/vec3(103.0, 71.0, 97.0));
float o8462_0_clamp_false = (elapsed_time)*p_o8462_default_in2;
float o8462_0_clamp_true = clamp(o8462_0_clamp_false, 0.0, 1.0);
float o8462_0_2_f = o8462_0_clamp_false;
float o8463_0_1_f = o8463_fbm((o8461_0_uv/vec2(p_o8461_x, p_o8461_y)), vec2(p_o8463_scale_x, p_o8463_scale_y), int(p_o8463_folds), int(p_o8463_iterations), p_o8463_persistence, o8462_0_2_f, (seed_o8463+_seed_variation_), _seed_variation_);
float o8462_3_clamp_false = (elapsed_time)*p_o8462_default_in2;
float o8462_3_clamp_true = clamp(o8462_3_clamp_false, 0.0, 1.0);
float o8462_0_5_f = o8462_3_clamp_false;
float o8457_0_1_f = o8457_fbm((fract(transform2((o8461_0_uv/vec2(p_o8461_x, p_o8461_y)), vec2((elapsed_time*.1)*(2.0*1.0-1.0), p_o50932_translate_y*(2.0*1.0-1.0)), p_o50932_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o50932_scale_x*(2.0*1.0-1.0), p_o50932_scale_y*(2.0*1.0-1.0))))), vec2(p_o8457_scale_x, p_o8457_scale_y), int(p_o8457_folds), int(p_o8457_iterations), p_o8457_persistence, o8462_0_5_f, (seed_o8457+_seed_variation_), _seed_variation_);
vec4 o50932_0_1_rgba = vec4(vec3(o8457_0_1_f), 1.0);
vec4 o8467_0_s1 = vec4(vec3(o8463_0_1_f), 1.0);
vec4 o8467_0_s2 = o50932_0_1_rgba;
float o8467_0_a = p_o8467_amount*1.0;
vec4 o8467_0_2_rgba = vec4(blend_difference((o8461_0_uv/vec2(p_o8461_x, p_o8461_y)), o8467_0_s1.rgb, o8467_0_s2.rgb, o8467_0_a*o8467_0_s1.a), min(1.0, o8467_0_s2.a+o8467_0_a*o8467_0_s1.a));
vec3 o8461_0_1_rgb = floor(((o8467_0_2_rgba).rgb)*p_o8461_c+p_o8461_d*(o8461_0_dither-vec3(0.5)))/p_o8461_c;
vec2 o24085_0_uv = floor(((uv)*vec2(p_o24085_x, p_o24085_y)))+vec2(0.5);
vec3 o24085_0_dither = fract(vec3(dot(vec2(171.0, 231.0), o24085_0_uv))/vec3(103.0, 71.0, 97.0));
float o8468_0_1_f = shape_circle((o24085_0_uv/vec2(p_o24085_x, p_o24085_y)), p_o8468_sides, p_o8468_radius*1.0, p_o8468_edge*1.0);
vec3 o24085_0_1_rgb = floor(vec3(o8468_0_1_f)*p_o24085_c+p_o24085_d*(o24085_0_dither-vec3(0.5)))/p_o24085_c;
vec4 o8469_0_s1 = vec4(o8461_0_1_rgb, 1.0);
vec4 o8469_0_s2 = vec4(o24085_0_1_rgb, 1.0);
float o8469_0_a = p_o8469_amount*1.0;
vec4 o8469_0_2_rgba = vec4(blend_darken((uv), o8469_0_s1.rgb, o8469_0_s2.rgb, o8469_0_a*o8469_0_s1.a), min(1.0, o8469_0_s2.a+o8469_0_a*o8469_0_s1.a));
vec4 o428250_0_1_rgba = o428250_gradient_gradient_fct((dot((o8469_0_2_rgba).rgb, vec3(1.0))/3.0));
vec4 o428250_0_3_rgba = o428250_gradient_gradient_fct((dot((o8469_0_2_rgba).rgb, vec3(1.0))/3.0));
float o629459_3_1_f = o428250_0_3_rgba.a;

	vec3 albedo_tex = ((o428250_0_1_rgba).rgb).rgb;
	albedo_tex = mix(pow((albedo_tex + vec3(0.055)) * (1.0 / (1.0 + 0.055)),vec3(2.4)),albedo_tex * (1.0 / 12.92),lessThan(albedo_tex,vec3(0.04045)));
	ALBEDO = albedo_tex*vec4(p_o8456_albedo_color_r, p_o8456_albedo_color_g, p_o8456_albedo_color_b, p_o8456_albedo_color_a).rgb;
	METALLIC = 1.0*p_o8456_metallic;
	ROUGHNESS = 1.0*p_o8456_roughness;
	NORMALMAP = vec3(0.5);
	EMISSION = vec3(0.0)*p_o8456_emission_energy;
	ALPHA = o629459_3_1_f;

}



