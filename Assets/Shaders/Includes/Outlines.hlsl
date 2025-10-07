SAMPLER(sampler_point_clamp);
float _PostMode;

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

void GetCrossSampleUVs_float(float2 uv, float2 TexelSize, float OffsetMultiplier, out float2 UVOriginal, out float2 UVTopRight, out float2 UVBottomLeft, out float2 UVTopLeft, out float2 UVBottomRight) {
    UVOriginal = uv;
    UVTopRight = uv + float2(TexelSize.x, TexelSize.y) * OffsetMultiplier;
    UVBottomLeft = uv - float2(TexelSize.x, TexelSize.y) * OffsetMultiplier;
    UVTopLeft = uv + float2(-TexelSize.x, TexelSize.y) * OffsetMultiplier;
    UVBottomRight = uv + float2(TexelSize.x, -TexelSize.y) * OffsetMultiplier;
}

void PostProcessing_float(float3 color, out float3 outColor) {
    if (_PostMode >= -0.5 && _PostMode < 0.5) {
        // greyScale
        float grey = dot(color, float3(0.2126, 0.7152, 0.0722));
        outColor = float3(grey, grey, grey);
    } else if (_PostMode >= 0.5 && _PostMode < 1.5) {
        // invert
        outColor  = float3(1.0 - color);
    } else if (_PostMode >= 1.5 && _PostMode < 2.5) {
        // saturation
        float grey = dot(color, float3(0.2126, 0.7152, 0.0722));
        float3 shade = float3(grey, grey, grey);
        outColor = color + (color - shade) * 2.0f;
    
    } else if (_PostMode >= 2.5 && _PostMode < 3.5) {
        // sepia 
        float grey = dot(color, float3(0.2126, 0.7152, 0.0722));
        float3 tone = float3(0.439, 0.258, 0.078);
        float3 shade = grey * tone;
        outColor = shade;
    } else {
        outColor = color;
    }
}





void wobbleUV_float(float2 uvIn, float2 screenSize, float time, bool timeDistort, out float2 uvWarped) {
    if (!timeDistort) {
        uvWarped = uvIn;
    }
    float speed = 2.0;
    float2 texel = 1.0 / screenSize;
    float t = floor(time * speed);
    float wobbleX = sin(0.5 * 11 * uvIn.x * 2.3 + 0.5 * 7 * uvIn.y * 1.3 + t);
    float wobbleY = cos(0.5 * 9 * uvIn.y * 3.1 + 0.5 * 13 * uvIn.y * 3.4 + t);
    float2 wobble = float2(wobbleX, wobbleY);

    uvWarped = uvIn + wobble * texel * 3.0;
}