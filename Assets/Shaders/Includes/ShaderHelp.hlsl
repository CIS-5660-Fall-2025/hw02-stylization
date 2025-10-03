
void DistortVertex_float(float3 WorldPos, float Time, float Intensity, float Scale, out float3 OUT)
{
    float dist = length(WorldPos.xz);

    float wave1 = sin(WorldPos.x * 0.15 * Scale + Time * 1.2) * 0.5;

    float wave2 = cos(WorldPos.z * 0.25 * Scale + Time * 0.9) * 0.35;

    float wave3 = sin((WorldPos.x + WorldPos.z) * 0.2 * Scale + Time * 1.8) * 0.25;
    
    float wave4 = sin(dist * 1.2 * Scale - Time * 2.2) * 0.2;

    float displacement = (wave1 + wave2 + wave3 + wave4) * Intensity;

    float3 pos = WorldPos;
    pos.y += displacement;

    OUT = pos;
}
