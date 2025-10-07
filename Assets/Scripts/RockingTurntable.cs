using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RockingTurntable : MonoBehaviour
{

    public float rotationSpeed = 1.0f;
    public float range = 1.0f;

    private Quaternion initialRotation;

    // Start is called before the first frame update
    void Start()
    {
        initialRotation = transform.localRotation;
    }

    // Update is called once per frame
    void Update()
    {
        float angle = range * Mathf.Sin(rotationSpeed * Time.time);

        Quaternion rotationQuaternion = Quaternion.AngleAxis(angle, Vector3.up);

        transform.localRotation = initialRotation * rotationQuaternion;
    }
}
