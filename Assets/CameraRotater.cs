using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraRotater : MonoBehaviour
{
    [SerializeField] float speed = 0.0f;
    void Update()
    {
        transform.rotation = Quaternion.AngleAxis(speed * Time.deltaTime, Vector3.up) * transform.rotation;
    }
}
