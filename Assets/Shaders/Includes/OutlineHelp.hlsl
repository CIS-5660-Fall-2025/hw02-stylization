SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}


static const float2 sobelOffsets[9] =
{
    float2(-1, -1), float2(0, -1), float2(1, -1),
    float2(-1, 0), float2(0, 0), float2(1, 0),
    float2(-1, 1), float2(0, 1), float2(1, 1)
};

static const float sobelX[9] =
{
    -1, 0, 1,
    -2, 0, 2,
    -1, 0, 1
};

static const float sobelY[9] =
{
    -1, -2, -1,
     0, 0, 0,
     1, 2, 1
};

void SobelEdge_float(float2 uv, float thickness, float2 screenDim, out float Edge)
{
    float x_d = 0, y_d = 0;
    float x_n = 0, y_n = 0;
    float2 texelSize = 1.0 / screenDim;

    [unroll]
    for (int i = 0; i < 9; i++)
    {
        
        float2 offsetUV = uv + sobelOffsets[i] * thickness * texelSize;

        // Depth
        float d;
        GetDepth_float(offsetUV, d);

        x_d += d * sobelX[i];
        y_d += d * sobelY[i];

        // Normals
        float3 n;
        GetNormal_float(offsetUV, n);
        float greyscale = (n.r + n.g + n.b) / 3.0;

        x_n += greyscale * sobelX[i];
        y_n += greyscale * sobelY[i];
    }

    float edgeDepth = sqrt(x_d * x_d + y_d * y_d);
    float edgeNormal = sqrt(x_n * x_n + y_n * y_n);

    Edge = min(edgeDepth, edgeNormal);
}
