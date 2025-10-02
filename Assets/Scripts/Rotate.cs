using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    public float amplitude = 30f;  
    public float speed = 60f;     

    float centerYaw; 

    void Start()
    {
        centerYaw = transform.localEulerAngles.y;
    }

    void Update()
    {
        float span = Mathf.Max(0.0001f, amplitude * 2f);
        float t = Mathf.PingPong(Time.time * (speed / span), 1f);
        float yaw = Mathf.Lerp(centerYaw - amplitude, centerYaw + amplitude, t);

        var e = transform.localEulerAngles;
        e.y = yaw;
        transform.localEulerAngles = e;
    }
}
