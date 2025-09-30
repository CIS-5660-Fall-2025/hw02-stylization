float stripe(float x, float rep, float stripeFac) {
    return step(abs(fmod(x, rep) - rep*.5), rep*.5*stripeFac);
}

void SampleTV_float(float2 UV, float TVScale, float Offset, out float Opacity) {
    float2 p = UV;
    
    // Sawtooth
    const float sawToothRep = 0.1;
    const float sawToothAmp = 0.03;
    float v = sawToothAmp*(1.-abs((fmod(p.x+1000.+Offset, sawToothRep)/sawToothRep)-.5));
    p.y += v;

    float s1 = stripe(p.y+1000.+Offset, TVScale*0.25, 0.8-0.15);
    float s2 = 0.*0.1*stripe(-p.y+1000.+0.7*Offset, TVScale*0.2, 0.7);

    Opacity = max(s1, s2);
}