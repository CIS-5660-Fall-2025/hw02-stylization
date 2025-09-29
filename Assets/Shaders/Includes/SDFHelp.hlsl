float smin( float a, float b, float k ) { // https://iquilezles.org/articles/smin/
    k *= 4.0;
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - h*h*k*(1.0/4.0);
}

float sdLine(float2 p, float2 start, float2 end, float thick) {
    float len = length(end-start);
    float2 dir = (end-start)/len;

    p -= start;
    float along = dot(p, dir);
    float against = length(p - dir*along);
    float2 lp = float2(along, against);

    lp.x -= len*.5;
    lp.x = abs(lp.x)-len*.5;
    lp.x = max(lp.x, 0.);

    return length(lp) - thick;   
}

void SampleClover_float(float2 UV, out float Opacity) {
    float2 p = UV;
    p.y += 0.005;
    p *= 5.*float2(1.,-1.);
    
    //
    const float r = 0.11+0.00*smoothstep(0., 0.3, length(p));
    const float k = 0.016-0.07*smoothstep(0., 0.3, length(p));
    const float2 offset = float2(0.,0.05);

    float2 p1 = float2(0., 0.13);
    float2 p2 = float2(-0.10,-0.05);
    float2 p3 = p2*float2(-1.,1.);
    p1 += offset; p2 += offset; p3 += offset;

    float d1 = length(p-p1)-r;
    float d2 = length(p-p2)-r;
    float d3 = length(p-p3)-r;

    float d = smin(smin(d1, d2, k), d3, k);

    //
    float2 lp = p;
    float u = p.y/(-.34);
    u *= u;
    lp.x -= 0.06*u;
    float dLine = sdLine(lp, float2(0.,0.), float2(0., -0.3), 0.02);
    d = smin(d, dLine, 0.001);

    Opacity = step(d, 0.);
}