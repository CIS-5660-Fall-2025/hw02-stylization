SAMPLER(sampler_point_clamp);

void GetDepth_float(float2 uv, out float Depth)
{
    Depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv);
}


void GetNormal_float(float2 uv, out float3 Normal)
{
    Normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv).rgb;
}

static float2 sobelSamplePoints[9] = {
    float2(-1,1), float2(0,1), float2(1,1),
    float2(-1,0), float2(0,0), float2(1,0),
    float2(-1,-1), float2(0,-1), float2(1,-1)
};

static float sobelXMatrix[9] = {
    1, 0, -1,
    2, 0, -2,
    1, 0, -1
};

static float sobelYMatrix[9] = {
    1, 2, 1,
    0, 0, 0,
    -1, -2, -1
};

void DepthSobel_float(float2 uv, float thickness, out float Out) {
    float2 sobel = 0;
    [unroll] for (int i = 0; i < 9; ++i) {
        float depth = SHADERGRAPH_SAMPLE_SCENE_DEPTH(uv + thickness * sobelSamplePoints[i]);
        sobel += depth * float2(sobelXMatrix[i], sobelYMatrix[i]);
    }
    Out = length(sobel);
}

void NormalSobel_float(float2 uv, float thickness, out float3 Out) {
    float3 sobelX = 0;
    float3 sobelY = 0;
    [unroll] for (int i = 0; i < 9; ++i) {
        float3 normal = SAMPLE_TEXTURE2D(_NormalsBuffer, sampler_point_clamp, uv + thickness * sobelSamplePoints[i]).rgb;
        sobelX += normal * sobelXMatrix[i];
        sobelY += normal * sobelYMatrix[i];
    }
    Out = float3(
        length(float2(sobelX.x, sobelY.x)),
        length(float2(sobelX.y, sobelY.y)),
        length(float2(sobelX.z, sobelY.z))
    );
}

// reusing random3D again from HW00, HW01...
float3 random3D( float3 p ) {
    return frac(sin(float3(dot(p, float3(127.1f, 311.7f, 191.999f)),
                                         dot(p, float3(269.5f, 183.3f, 773.2f)),
                                         dot(p, float3(103.37f, 217.83f, 523.7f)))) * 43758.5453f);
}

#define TAU 6.2831853071f

void WorleyT_float(float2 uv, float t, out float2 Perturb) {
    // implementing own Worley noise in order to do 3D (one being time) rather than 2D
    float3 p = float3(uv,t);
    
    float3 pFloor = floor(p);
    float3x3 rotMat = float3x3(0.7258497, -0.2747445, -0.6306010,
   0.5369684, -0.3466323,  0.7690976,
  -0.4298920, -0.8968620, -0.1040739);
    float3 p2 = mul(rotMat, p);
    float3 p2Floor = floor(p2);
    float2 minDist = 1000.f;
    // int cell = 0;
    float3 cellPos = 0.0;
    for (int dz = -1; dz <= 1; ++dz) {
        for (int dy = -1; dy <= 1; ++dy) {
            for (int dx = -1; dx <= 1; ++dx) {
                float3 gridPoint = pFloor + float3(dx,dy,dz);
                float3 gridPoint2 = p2Floor + float3(dx,dy,dz);
                float3 samplePoint = random3D(gridPoint) + gridPoint;
                float3 samplePoint2 = random3D(gridPoint2) + gridPoint2;

                // float curDist = length(samplePoint - p);
                float2 curDist = float2(length(samplePoint - p), length(samplePoint2 - p2));
                if (minDist.x > curDist.x) {
                    minDist.x = curDist.x;
                }
                if (minDist.y > curDist.y) {
                    minDist.y = curDist.y;
                    cellPos = gridPoint2;
                }
                // minDist = min(minDist, curDist);
            }
        }

    }
    float rot = random3D(cellPos).x * TAU;

    // minDist.y *= TAU;
    Perturb = float2(cos(rot), sin(rot)) * minDist.x;
    // Perturb = float2(cos(minDist.y), sin(minDist.y)) * minDist.x;
}