using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Turntable : MonoBehaviour
{

    public float rotationSpeed = 1.0f;
    Transform target;

    void Awake()
    {
        // to make stuff easier, I set the camera to rotate around the main object in the scene
        var findPivot = GameObject.Find("Hornet");
        target = findPivot.transform;
    }

    // Update is called once per frame
    void Update()
    {
        this.transform.RotateAround(target.position, Vector2.up, rotationSpeed * Time.deltaTime);
        // this.transform.Rotate(0, rotationSpeed * Time.deltaTime, 0);
    }
}
