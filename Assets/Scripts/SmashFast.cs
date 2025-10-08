using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SmashFast : MonoBehaviour
{
    private static readonly int WavingSpeedID = Shader.PropertyToID("_Waving_speed");

    private Renderer rend;
    private MaterialPropertyBlock mpb;
    private float speed;
    private int flip = 1;

    // Start is called before the first frame update
    void Start()
    {
        rend = GetComponent<Renderer>();
        mpb = new MaterialPropertyBlock();

        var mat = rend.sharedMaterial;
        speed = mat.GetFloat(WavingSpeedID);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            speed += 6 * flip;
            flip *= -1;
            mpb.SetFloat(WavingSpeedID, speed);
            rend.SetPropertyBlock(mpb);
        }
    }
}
