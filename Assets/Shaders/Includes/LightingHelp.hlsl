void GetMainLight_float(float3 WorldPos, out float3 Color, out float3 Direction, out float DistanceAtten, out float ShadowAtten)
{
#ifdef SHADERGRAPH_PREVIEW
	Direction = normalize(float3(0.5, 0.5, 0));
	Color = 1;
	DistanceAtten = 1;
	ShadowAtten = 1;
#else
#if SHADOWS_SCREEN
	float4 clipPos = TransformWorldToClip(WorldPos);
	float4 shadowCoord = ComputeScreenPos(clipPos);
#else
	float4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
#endif

	Light mainLight = GetMainLight(shadowCoord);
	Direction = mainLight.direction;
	Color = mainLight.color;
	DistanceAtten = mainLight.distanceAttenuation;
	ShadowAtten = mainLight.shadowAttenuation;
#endif
}

void ComputeAdditionalLighting_float(float3 WorldPosition, float3 WorldNormal,
	float2 Thresholds, float3 RampedDiffuseValues,
	out float3 Color, out float Diffuse)
{
	Color = float3(0, 0, 0);
	Diffuse = 0;

#ifndef SHADERGRAPH_PREVIEW

	int pixelLightCount = GetAdditionalLightsCount();

	for (int i = 0; i < pixelLightCount; ++i)
	{
		Light light = GetAdditionalLight(i, WorldPosition);
		float4 tmp = unity_LightIndices[i / 4];
		uint light_i = tmp[i % 4];

		half shadowAtten = light.shadowAttenuation * AdditionalLightRealtimeShadow(light_i, WorldPosition, light.direction);

		half NdotL = saturate(dot(WorldNormal, light.direction));
		half distanceAtten = light.distanceAttenuation;

		half thisDiffuse = distanceAtten * shadowAtten * NdotL;

		half rampedDiffuse = 0;

		if (thisDiffuse < Thresholds.x)
		{
			rampedDiffuse = RampedDiffuseValues.x;
		}
		else if (thisDiffuse < Thresholds.y)
		{
			rampedDiffuse = RampedDiffuseValues.y;
		}
		else
		{
			rampedDiffuse = RampedDiffuseValues.z;
		}


		if (light.distanceAttenuation <= 0)
		{
			rampedDiffuse = 0.0;
		}

		Color += max(rampedDiffuse, 0) * light.color.rgb;
		Diffuse += rampedDiffuse;
	}

	if (Diffuse <= 0.3)
	{
		Color = float3(0, 0, 0);
		Diffuse = 0;
	}

#endif
}

void ChooseColor_float(float3 Highlight, float3 Midtone, float3 Shadow, float Diffuse, float2 Thresholds, float2 powerLerp, out float3 OUT)
{
	if (Diffuse < Thresholds.x)
	{
		OUT = Shadow;
	}
	else if (Diffuse < Thresholds.y)
	{
		float t = (Diffuse - Thresholds.x) / (Thresholds.y - Thresholds.x);
		t = pow(t, powerLerp.x);
		OUT = lerp(Shadow, Midtone, t);
	}
	else
	{
		float t = (Diffuse - Thresholds.y) / (1.0 - Thresholds.y);
		t = pow(t, powerLerp.y);
		OUT = lerp(Midtone, Highlight, t);
	}
}

void ChooseUV_float(float3 objPos, UnityTexture2D tex,
	UnitySamplerState tex_sampler,
	float zoom,
	out float3 color) {
	float3 p = normalize(objPos);
	float3 blend = pow(abs(p), 4.0);
	blend /= dot(blend, 1.0);

	p *= zoom;

	float3 xColor = SAMPLE_TEXTURE2D(tex, tex_sampler, p.zy).rgb;
	float3 yColor = SAMPLE_TEXTURE2D(tex, tex_sampler, p.xz).rgb;
	float3 zColor = SAMPLE_TEXTURE2D(tex, tex_sampler, p.xy).rgb;

	color = xColor * blend.x + yColor * blend.y + zColor * blend.z;
}


float LinearEyeDepth(float rawDepth)
{
	float z = rawDepth * 2.0 - 1.0;
	return 2.0 * _ProjectionParams.z * _ProjectionParams.y / (_ProjectionParams.y + _ProjectionParams.x - z * (_ProjectionParams.y - _ProjectionParams.x));
}


void ChooseDepthBlurColor_float(float2 UV, float2 TexelSize, float Threshold, float BlurScale, out float4 OutColor, out bool blurred)
{
	// 3x3 Gaussian kernel weights
	float w[9] = {
		1.0 / 16.0, 2.0 / 16.0, 1.0 / 16.0,
		2.0 / 16.0, 4.0 / 16.0, 2.0 / 16.0,
		1.0 / 16.0, 2.0 / 16.0, 1.0 / 16.0
	};
	float2 baseOffset[9] = {
		float2(-1, -1), float2(0, -1), float2(1, -1),
		float2(-1,  0), float2(0,  0), float2(1,  0),
		float2(-1,  1), float2(0,  1), float2(1,  1)
	};

	float centerDepth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV);
	float4 centerColor = float4(SHADERGRAPH_SAMPLE_SCENE_COLOR(UV).rgb, 1);
	OutColor = centerColor;
	blurred = false;
	return;
	// Convert raw depth to linear depth (0 = near plane, 1 = far plane)
	// For orthographic: depth is already linear
	// For perspective: need to linearize
#if defined(UNITY_REVERSED_Z)
	// Reversed-Z: 1 is near, 0 is far
	float linearDepth = Linear01Depth(centerDepth, _ZBufferParams);
#else
	float linearDepth = Linear01Depth(centerDepth, _ZBufferParams);
#endif

	// Scale blur radius based on depth (farther = more blur)
	// linearDepth ranges from 0 (near) to 1 (far plane distance)
	float depthBlurMultiplier = lerp(1.0, BlurScale, linearDepth);

	// Calculate actual offsets with depth-based scaling
	float2 offset[9];
	for (int j = 0; j < 9; j++)
	{
		offset[j] = baseOffset[j] * TexelSize * depthBlurMultiplier;
		offset[j].x *= (1 + sin(_Time.y + 23456.2355744) / 10);
		offset[j].y *= (1 + cos(_Time.y + 87654.98765) / 10);

	}

	// Compute the maximum local depth difference for edge detection
	float maxDiff = 0.0;
	for (int i = 0; i < 9; i++)
	{
		float d = SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV + offset[i]);
		maxDiff = max(maxDiff, abs(centerDepth - d));
	}

	// If big depth change, skip blur (edge)
	if (maxDiff > Threshold)
	{
		OutColor = centerColor;
		blurred = false;
		return;
	}

	blurred = true;

	// Otherwise, blur the scene color using Gaussian kernel
	float4 blurSum = float4(0, 0, 0, 0);
	float weightSum = 0.0;

	for (int i = 0; i < 9; i++)
	{
		float neighborDepth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV + offset[i]);

		// Weight neighbors less if depth differs (soft edge preservation)
		float depthDiff = abs(centerDepth - neighborDepth);
		float depthWeight = saturate(1.0 - depthDiff / Threshold);

		float4 sampleCol = float4(SHADERGRAPH_SAMPLE_SCENE_COLOR(UV + offset[i]), 1);
		float wFinal = w[i] * depthWeight;

		blurSum += sampleCol * wFinal;
		weightSum += wFinal;
	}

	OutColor = blurSum / weightSum;
}


static float fadef(float t) {
	return t * t * t * (t * (t * 6 - 15) + 10);
}

static float hash1(float n) {
	return frac(sin(n) * 43758.5453123);
}

static float3 hash3(float3 p) {
	float n = dot(p, float3(1.0, 57.0, 113.0));
	float h = hash1(n);
	return frac(float3(h, hash1(n + 31.416), hash1(n + 71.13)));
}

static float grad(float3 ip, float3 fp) {
	float3 h = hash3(ip) * 2.0 - 1.0;
	h = normalize(h);
	return dot(h, fp);
}

static float perlin3_scalar(float3 p) {
	float3 pi = floor(p);
	float3 pf = p - pi;
	float3 w = float3(fadef(pf.x), fadef(pf.y), fadef(pf.z));

	float n000 = grad(pi + float3(0, 0, 0), pf - float3(0, 0, 0));
	float n100 = grad(pi + float3(1, 0, 0), pf - float3(1, 0, 0));
	float n010 = grad(pi + float3(0, 1, 0), pf - float3(0, 1, 0));
	float n110 = grad(pi + float3(1, 1, 0), pf - float3(1, 1, 0));
	float n001 = grad(pi + float3(0, 0, 1), pf - float3(0, 0, 1));
	float n101 = grad(pi + float3(1, 0, 1), pf - float3(1, 0, 1));
	float n011 = grad(pi + float3(0, 1, 1), pf - float3(0, 1, 1));
	float n111 = grad(pi + float3(1, 1, 1), pf - float3(1, 1, 1));

	float nx00 = lerp(n000, n100, w.x);
	float nx10 = lerp(n010, n110, w.x);
	float nx01 = lerp(n001, n101, w.x);
	float nx11 = lerp(n011, n111, w.x);

	float nxy0 = lerp(nx00, nx10, w.y);
	float nxy1 = lerp(nx01, nx11, w.y);

	float nxyz = lerp(nxy0, nxy1, w.z);

	return nxyz;
}

void GradientNoise3D_float(float3 position, float frequency, float amplitude, out float outColor)
{
	float3 p = position * frequency;

	float3 offsetA = float3(0.0, 0.0, 0.0);
	float3 offsetB = float3(31.416, 47.853, 12.793);
	float3 offsetC = float3(17.11, 9.99, 73.2);

	float s1 = perlin3_scalar(p + offsetA);
	float s2 = perlin3_scalar(p + offsetB);
	float s3 = perlin3_scalar(p + offsetC);

	outColor = s1 * s2 * s3 * 3;
}

void GradientNoise3D_Stretched_float(
	float3 position, float frequency, float seamFrequency, float seamWidth, float stretch, float seed, out float result)
{
	position *= frequency;
	float2 xz = position.xz * seamFrequency;

	float jitter = hash1(xz.y + seed) * 0.5;
	float periodic = frac(xz.x + jitter);
	float seamDist = abs(periodic - 0.5);

	float yVar = perlin3_scalar(float3(position.x * 0.05, position.y * 0.05 / stretch, position.z * 0.05 + seed));
	yVar = yVar * 0.5 + 0.5;
	float drift = smoothstep(0.3, 0.7, yVar);

	float inSeam = step(seamDist, seamWidth);
	float mask = inSeam * drift;

	mask = step(0.5, mask);
	result = mask;
}