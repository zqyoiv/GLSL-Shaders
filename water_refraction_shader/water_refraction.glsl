out vec4 fragColor;
void main()
{
	vec3 surfaceNormal = texture(sTD2DInputs[0], vUV.st).rgb;
	vec3 lightDirection = vec3(0, -1, 0); // directy down in y axis
	// 1.0: index refraction of air; 1.33: index refraction of water.
	vec3 refracted = refract(lightDirection, surfaceNormal, 1.0 / 1.33); 
	refracted = normalize(refracted);
	
	// build our intersection plane
	vec3 planeNormal = vec3(0, 1, 0); // direct opposite of light, directly up.
	vec3 p0 = vec3(0, -0.5, 0); // point on the plane. set the intersection plane below refractive surface.
	
	// build our ray
	vec3 r0 = vec3(vUV.s, 0., vUV.t);
	vec3 rayDirection = refracted;
	
	float t = -dot(r0 - p0, planeNormal) / dot(rayDirection, planeNormal);

	// intersect with plane
	vec3 planeIntersect = r0 + t * rayDirection;
	
	vec4 color = vec4(planeIntersect, 1.0);
	fragColor = TDOutputSwizzle(color);
}