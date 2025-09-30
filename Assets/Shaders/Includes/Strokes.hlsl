
float3 random3(float3 p)
{
    return frac(sin(float3(
        dot(p, float3(127.1, 311.7, 74.7)),
        dot(p, float3(269.5, 183.3, 246.1)),
        dot(p, float3(113.5, 271.9, 124.6))
    )) * 43758.5453);
}

float voronoi3D(float3 xyz, int gridSize, out float3 closestCell, out float3 closerCell)
{
    float3 stw = xyz * float(gridSize);

    float3 i = floor(stw);
    float3 f = frac(stw);

    float minDist = 100.0;
    closestCell = i;
    closerCell = i; // TEMP

    [loop]
    for (int x = -1; x <= 1; x++)
    {
        for (int y = -1; y <= 1; y++)
        {
            for (int z = -1; z <= 1; z++)
            {
                float3 offset = float3((float) x, (float) y, (float) z);
                float3 randomPt = random3(i + offset);
                float currDist = length(f - (randomPt + offset));

                if (currDist < minDist)
                {
                   
                    closestCell = i + offset;
                    minDist = currDist;
                }
            }
        }
    }
    return minDist;
}




// Value noise 3D by iq (converted to HLSL)
// https://www.shadertoy.com/view/4sfGzS

float hash(int3 p)   // simple integer-based hash
{
    // 3D -> 1D
    int n = p.x * 3 + p.y * 113 + p.z * 311;

    // 1D hash by Hugo Elias
    n = (n << 13) ^ n;
    n = n * (n * n * 15731 + 789221) + 1376312589;

    // mask & normalize
    return (float) (n & 0x0fffffff) / (float) 0x0fffffff;
}

float valueNoise3D(float3 x)
{
    int3 i = (int3) floor(x); // integer cell
    float3 f = frac(x); // local position
    f = f * f * (3.0 - 2.0 * f); // smoothstep interpolation

    return lerp(
        lerp(
            lerp(hash(i + int3(0, 0, 0)),
                 hash(i + int3(1, 0, 0)), f.x),
            lerp(hash(i + int3(0, 1, 0)),
                 hash(i + int3(1, 1, 0)), f.x), f.y),
        lerp(
            lerp(hash(i + int3(0, 0, 1)),
                 hash(i + int3(1, 0, 1)), f.x),
            lerp(hash(i + int3(0, 1, 1)),
                 hash(i + int3(1, 1, 1)), f.x), f.y),
        f.z);
}

float fbm(float3 p)
{
    // PARAMETERS
    const int iterCount = 3;
    float ampDecreaseFactor = 0.5;
    float freqIncreaseFactor = 2.0;
    float amp = 0.5; // INITIAL AMP

    // base values
    float fbmSum = 0.0;
    float3 seed = p;

    [loop]
    for (int i = 0; i < iterCount; i++)
    {
        fbmSum += valueNoise3D(seed) * amp;

        // decreasing factors
        amp *= ampDecreaseFactor;
        seed *= freqIncreaseFactor;
    }
    return fbmSum;
}


void createStrokes_float(float3 baseCol, float2 uv, out float3 OUT)
{
    // uv = mul(rotate2d(uv.x + uv.y), uv);

    // UV DISTORTION
    uv += 0.1 * fbm(float3(uv, 0.0) * 100.0);
    
    int gridNum = 20.;
    float3 closestCell;
    float3 closerCell;
    
    float seed = voronoi3D(float3(uv, 2.0), gridNum, closestCell, closerCell);

    // 0 NORMALIZED, GRADIENT
    float3 finalCol = closestCell / float3(gridNum, gridNum, gridNum); // NORMALIZED, GRADIENT
    
    // 1
    //float3 variation = random3(closestCell) * 0.2 - 0.1; // [-0.1, 0.1]
    //finalCol = saturate(baseCol * variation);
    
    // 2
    //float3 cellVariation = closestCell / float3(gridNum, gridNum, gridNum);
    //float3 finalCol = baseCol + (cellVariation - 0.5) * 0.8;
    
    //float3 variation = random3(closestCell) * 0.2 - 0.1; // [-0.1, 0.1]
    //float3 finalCol = (baseCol + variation);
    
    
    OUT = finalCol;
}

void computeNormalVoronoi_float(float3 seed, float gridSize, out float3 OUT)
{
    float3 closerCell; // temp
    float3 closestCellid;
    voronoi3D(seed, (int)gridSize, closestCellid, closerCell);
    
    
    float3 closestCellNormalized = closestCellid / float3(gridSize, gridSize, gridSize);
    OUT = closestCellNormalized;

}