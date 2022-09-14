#version 460

layout(location=0) in vec3 vertex_POSITION;
out vec3 fragment_POSITION;
layout(location=1) in vec3 vertex_NORMAL;
out vec3 fragment_NORMAL;
layout(location=2) in vec2 vertex_TEXCOORD_0;
out vec2 fragment_TEXCOORD_0;


layout(binding = 2) uniform sampler2D u_color_texture;
layout(binding = 3) uniform sampler2D u_metal_roughness_texture;
layout(binding = 4) uniform sampler2D u_normal_textures;
uniform float u_normal_scale;

//// Materials
// PBR
uniform vec4 u_color_factor;
uniform float u_metal;
uniform float u_roughness;
// Material
uniform vec3 u_emission_factor;

layout(row_major, std140, binding=0) uniform Camera {
	mat4 projectionMatrix;
	mat4 cameraMatrix;
	vec3 cameraLocation;
};

uniform mat4 nodeMatrix;

out vec4 gl_Position;
out vec3 fragment_location;

void main(){
		fragment_POSITION = vertex_POSITION;
	fragment_NORMAL = vertex_NORMAL;
	fragment_TEXCOORD_0 = vertex_TEXCOORD_0;


	vec4 plek4 = nodeMatrix * vec4(vertex_POSITION, 1.0);
	gl_Position = projectionMatrix * cameraMatrix * plek4;

	fragment_location = plek4.xyz/plek4.w;
}
