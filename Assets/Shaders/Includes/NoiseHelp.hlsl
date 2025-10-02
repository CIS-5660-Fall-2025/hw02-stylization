float hash31(float3 p3) // From https://www.shadertoy.com/view/4djSRW
{
	p3  = frac(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return frac((p3.x + p3.y) * p3.z);
}

float3 hash33(float3 p3) // From https://www.shadertoy.com/view/4djSRW
{
	p3 = frac(p3 * float3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz+33.33);
    return frac((p3.xxy + p3.yxx)*p3.zyx);

}

float3x3 rotZ(float o) {
    return float3x3(cos(o), sin(o), 0., -sin(o), cos(o), 0., 0., 0., 1.);
}

float3x3 rotX(float o) {
    return float3x3(1., 0., 0., 0., cos(o), sin(o), 0., -sin(o), cos(o));
}

float noise(float3 p) {
    float3 lp = frac(p);
    float3 id = floor(p);

    float2 d = float2(1.,0.);

    float r000 = hash31(id+d.yyy);
    float r001 = hash31(id+d.yyx);
    float r010 = hash31(id+d.yxy);
    float r011 = hash31(id+d.yxx);
    float r100 = hash31(id+d.xyy);
    float r101 = hash31(id+d.xyx);
    float r110 = hash31(id+d.xxy);
    float r111 = hash31(id+d.xxx);

    float r00 = lerp(r000, r001, lp.z);
    float r01 = lerp(r010, r011, lp.z);
    float r10 = lerp(r100, r101, lp.z);
    float r11 = lerp(r110, r111, lp.z);

    float r0 = lerp(r00, r01, lp.y);
    float r1 = lerp(r10, r11, lp.y);

    float r = lerp(r0, r1, lp.x);

    return r;
}

float3 noise3D(float3 p) {
    float3 lp = frac(p);
    float3 id = floor(p);

    float2 d = float2(1.,0.);

    float3 r000 = hash33(id+d.yyy);
    float3 r001 = hash33(id+d.yyx);
    float3 r010 = hash33(id+d.yxy);
    float3 r011 = hash33(id+d.yxx);
    float3 r100 = hash33(id+d.xyy);
    float3 r101 = hash33(id+d.xyx);
    float3 r110 = hash33(id+d.xxy);
    float3 r111 = hash33(id+d.xxx);

    float3 r00 = lerp(r000, r001, lp.z);
    float3 r01 = lerp(r010, r011, lp.z);
    float3 r10 = lerp(r100, r101, lp.z);
    float3 r11 = lerp(r110, r111, lp.z);

    float3 r0 = lerp(r00, r01, lp.y);
    float3 r1 = lerp(r10, r11, lp.y);

    float3 r = lerp(r0, r1, lp.x);

    return r;
}

void FBM_float(float3 p, float scale, float iterations, out float VAL) {
    p *= scale;

    float3x3 rot = rotX(32.53) * rotZ(18.4) * rotX(41.2);

    float scaleMult = 2.;
    float decay = .5;
    
    float sum = 0.;
    float currMult = .5;

    float3 q = p;
    for(int i=0; i<int(iterations); i++) {
        sum += noise(q)*currMult;

        q *= scaleMult;
        q += float3(13.513,591.,219.);
        q = mul(rot, q);
        currMult *= decay;
    }

    VAL = sum;
}

void FBM3D_float(float3 p, float scale, float iterations, out float3 VAL) {
    p *= scale;

    float3x3 rot = rotX(32.53) * rotZ(18.4) * rotX(41.2);

    float scaleMult = 2.;
    float decay = .5;
    
    float3 sum = 0.;
    float currMult = .5;

    float3 q = p;
    for(int i=0; i<int(iterations); i++) {
        sum += noise3D(q)*currMult;

        q *= scaleMult;
        q += float3(13.513,591.,219.);
        q = mul(rot, q);
        currMult *= decay;
    }

    VAL = sum;
}