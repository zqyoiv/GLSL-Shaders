uniform float uAlphaFront;
uniform float uShadowStrength;
uniform vec3 uShadowColor;
uniform vec3 uDiffuseColor;
uniform vec3 uAmbientColor;
uniform vec3 uSpecularColor;
uniform float uShininess;

uniform float uNumInstances;
uniform vec3 uStartRotation, uEndRotation;

out Vertex
{
	vec4 color;
	vec3 worldSpacePos;
	vec3 worldSpaceNorm;
	vec2 texCoord0;
	flat int cameraIndex;
} oVert;

void main()
{
    // get instance specific value from 0 to 1
    float pct = TDInstanceID() / uNumInstances;
    // calculate instance rotation
    vec3 rot = mix(uStartRotation, uEndRotation, pct);
    
    // location of each vertex
    vec4 npos = TDDeform(P);
    npos *= rotMatXYZ(rot.x, rot.y, rot.z);

	gl_PointSize = 1.0;
	{ // Avoid duplicate variable defs
		vec3 curTexCoord = TDTexCoord(0);
		vec3 texcoord = TDInstanceTexCoord(curTexCoord);
		oVert.texCoord0.st = texcoord.st;
	}
	vec3 pos = TDPos();
	vec3 normal = TDNormal();
	// First deform the vertex and normal
	// TDDeform always returns values in world space
	vec4 worldSpacePos = TDDeform(npos);
	vec3 uvUnwrapCoord = TDInstanceTexCoord(TDUVUnwrapCoord());
	gl_Position = TDWorldToProj(worldSpacePos, uvUnwrapCoord);


	// This is here to ensure we only execute lighting etc. code
	// when we need it. If picking is active we don't need lighting, so
	// this entire block of code will be ommited from the compile.
	// The TD_PICKING_ACTIVE define will be set automatically when
	// picking is active.
#ifndef TD_PICKING_ACTIVE

	int cameraIndex = TDCameraIndex();
	oVert.cameraIndex = cameraIndex;
	oVert.worldSpacePos.xyz = worldSpacePos.xyz;
	oVert.color = TDInstanceColor(TDColor());
	vec3 worldSpaceNorm = normalize(TDDeformNorm(normal));
	oVert.worldSpaceNorm.xyz = worldSpaceNorm;

#else // TD_PICKING_ACTIVE

	// This will automatically write out the nessessary values
	// for this shader to work with picking.
	// See the documentation if you want to write custom values for picking.
	TDWritePickingValues();

#endif // TD_PICKING_ACTIVE
}
