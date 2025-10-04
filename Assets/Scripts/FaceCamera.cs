using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FaceCamera : MonoBehaviour
{
    [SerializeField] private Transform cam;

    void Start() {
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 dir = cam.position - transform.position;
        dir.y = 0f;

        transform.rotation = Quaternion.LookRotation(dir, Vector3.up);
    }
}
