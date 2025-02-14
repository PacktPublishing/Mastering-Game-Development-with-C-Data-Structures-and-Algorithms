#version 330 core

layout(location = 0) in vec3 vertexPosition_modelspace;
layout(location = 2) in vec3 vertexNormal_modelspace;
layout(location = 1) in vec2 vertexUV;
layout(location = 4) in vec3 vertexTangent_modelspace;

// Output data 
out vec4 vcolor;
out vec2 UV;
out vec3 Position_worldspace;
out vec3 EyeDirection_cameraspace;
out vec3 LightDirection_cameraspace;
out vec3 LightDirection_tangentspace;
out vec3 EyeDirection_tangentspace;

// Values that stay constant for the whole mesh.
uniform mat4 matView;
uniform mat4 matModel;
uniform mat4 matProjection;
uniform vec3 LightPosition_worldspace;
uniform vec4 colDiffuse;

void main(){

        mat3 MV3x3 = mat3(matView*matModel);

	
	// Position of the vertex, in worldspace : M * position
	Position_worldspace = (matModel * vec4(vertexPosition_modelspace,1)).xyz;
	
	// Vector that goes from the vertex to the camera, in camera space.
	// In camera space, the camera is at the origin (0,0,0).
	vec3 vertexPosition_cameraspace = (matView * vec4(Position_worldspace,1)).xyz;

	// Output position of the vertex, in clip space : MVP * position
	gl_Position =  matProjection * vec4(vertexPosition_cameraspace,1);

	//EyeDirection_cameraspace = vec3(0,0,0) - vertexPosition_cameraspace;
	EyeDirection_cameraspace = vertexPosition_cameraspace;

	// Vector that goes from the vertex to the light, in camera space. M is ommited because it's identity.
	vec3 LightPosition_cameraspace = (matView * vec4(LightPosition_worldspace,1)).xyz;
	LightDirection_cameraspace = LightPosition_cameraspace + EyeDirection_cameraspace;
	
	// UV of the vertex. No special space for this one.
	UV = vertexUV;

        //calculate bi-tangent
        vec3 vertexBitangent_modelspace = cross(vertexNormal_modelspace, vertexTangent_modelspace);
	
	// model to camera = ModelView
	vec3 vertexTangent_cameraspace = MV3x3 * vertexTangent_modelspace;
	vec3 vertexBitangent_cameraspace = MV3x3 * vertexBitangent_modelspace;
	vec3 vertexNormal_cameraspace = MV3x3 * vertexNormal_modelspace;
	
	mat3 TBN = transpose(mat3(
		vertexTangent_cameraspace,
		vertexBitangent_cameraspace,
		vertexNormal_cameraspace	
	)); // You can use dot products instead of building this matrix and transposing it. See References for details.

	LightDirection_tangentspace = TBN * LightDirection_cameraspace;
	EyeDirection_tangentspace =  TBN * EyeDirection_cameraspace;
	
	vcolor = colDiffuse;
}

