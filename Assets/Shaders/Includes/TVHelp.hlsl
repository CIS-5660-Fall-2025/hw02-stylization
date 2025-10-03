float cubicPulse(float c, float w, float x) { // From toolbox slides
    x = abs(x);
    if(x >w) return 0.;
    x /= w;
    return 1.-x*x*(3.-2.*x);
}

float stripe(float x, float rep, float stripeFac) {
    return step(abs(fmod(x, rep) - rep*.5), rep*.5*stripeFac);
}

float hash11(float p) // From https://www.shadertoy.com/view/4djSRW
{
    p = frac(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return frac(p);
}

void SampleTVBrightness_float(float Time, out float BrightnessFac) {
    const float repTime = 1.;
    const float pulseFac = 0.78;

    float lt = fmod(Time, repTime) - repTime*.5;
    lt /= repTime*.5;
    float pulse = cubicPulse(0., pulseFac, lt);

    BrightnessFac = pulse;//sin(Time*10.)*.5+.5;//pulse;
}

void DistortTVUV_float(float2 UV, float StripeRepSize, float OffsetMultiplier, float HashOffset, out float2 UVOutput) {
    float2 p = UV + float2(0.,1000.);

    float yID = StripeRepSize*floor(p.y/StripeRepSize);
    float off = hash11(yID+HashOffset)*2.-1.;
    off *= OffsetMultiplier;

    UVOutput = UV + float2(off, 0.);
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