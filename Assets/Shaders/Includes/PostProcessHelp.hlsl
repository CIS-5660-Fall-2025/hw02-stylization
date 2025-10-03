void Tint_float(float3 SceneColor, float3 TintColor, out float3 Color) {
    const float3 colToGray = float3(0.2126, 0.7152, 0.0722); // From https://gmshaders.com/tutorials/basic_colors/

    float gray = dot(SceneColor, colToGray);
    Color = TintColor * gray;
}