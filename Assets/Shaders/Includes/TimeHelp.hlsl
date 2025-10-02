void PosterizeTime_float(float Time, float Framerate, out float PosterizedTime) {
    float repTime = 1./Framerate;
    PosterizedTime = floor(Time/repTime)*repTime;
}