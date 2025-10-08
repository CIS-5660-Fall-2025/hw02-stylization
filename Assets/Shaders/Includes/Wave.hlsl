void Wave_float(
    float3 position, float WavingSpeed, float WavingDegree,
    float3 WavingPivot, float3 WavingAxis,
    out float3 positionOut)
{
    float3 axis = normalize(WavingAxis);

    float t = _Time.y; 
    float angleRad = radians(WavingDegree) * sin(t * WavingSpeed);

    float3 p = position - WavingPivot;
    float s = sin(angleRad);
    float c = cos(angleRad);
    float3 k = axis;

    float3 rotated = p * c + cross(k, p) * s + k * dot(k, p) * (1 - c);

    positionOut = WavingPivot + rotated;
}