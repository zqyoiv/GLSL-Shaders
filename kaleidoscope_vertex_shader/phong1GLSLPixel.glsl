uniform float uAlphaFront;
uniform float uShadowStrength;
uniform vec3 uShadowColor;
uniform vec3 uDiffuseColor;
uniform vec3 uAmbientColor;
uniform vec3 uSpecularColor;
uniform float uShininess;
uniform sampler2D sColorMap;

uniform float uNumInstances; 

in Vertex
{
	vec4 color;
	vec3 worldSpacePos;
	vec3 worldSpaceNorm;
	vec2 texCoord0;
	flat int cameraIndex;
} iVert;

// Output variable for the color
layout(location = 0) out vec4 oFragColor[TD_NUM_COLOR_BUFFERS];
void main()
{
	// This allows things such as order independent transparency
	// and Dual-Paraboloid rendering to work properly
	TDCheckDiscard();

	// This will hold the combined color value of all light sources
	vec3 lightingColor = vec3(0.0, 0.0, 0.0);
	vec3 diffuseSum = vec3(0.0, 0.0, 0.0);
	vec3 specularSum = vec3(0.0, 0.0, 0.0);

	vec3 worldSpaceNorm = normalize(iVert.worldSpaceNorm.xyz);
	vec3 normal = normalize(worldSpaceNorm.xyz);
	vec2 texCoord0 = iVert.texCoord0.st;

    // read in color from sampler map
	vec4 colorMapColor = texture(sColorMap, texCoord0.st);
    vec3 oCol = colorMapColor.rgb;
    float oAlpha = colorMapColor.a;

	vec3 viewVec = normalize(uTDMats[iVert.cameraIndex].camInverse[3].xyz - iVert.worldSpacePos.xyz );

	vec4 color = TDPixelColor(iVert.color);

	vec4 finalColor = colorMapColor;
	finalColor.rgb *= finalColor.a;
	finalColor *= colorMapColor;

	finalColor *= color;

	// Apply fog, this does nothing if fog is disabled
	finalColor = TDFog(finalColor, iVert.worldSpacePos.xyz, iVert.cameraIndex);

	// Dithering, does nothing if dithering is disabled
	finalColor = TDDither(finalColor);

    finalColor /= uNumInstances;

	// Modern GL removed the implicit alpha test, so we need to apply
	// it manually here. This function does nothing if alpha test is disabled.
	TDAlphaTest(finalColor.a);

	oFragColor[0] = TDOutputSwizzle(finalColor);


	// TD_NUM_COLOR_BUFFERS will be set to the number of color buffers
	// active in the render. By default we want to output zero to every
	// buffer except the first one.
	for (int i = 1; i < TD_NUM_COLOR_BUFFERS; i++)
	{
		oFragColor[i] = vec4(0.0);
	}
}
