using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bob : MonoBehaviour
{
    public float moveSpeed = 2f;
    public float moveHeight = 1f;
    private Vector3 startPosition;

    void Start() {
        startPosition = transform.position;
    }

    void Update() {
        float newY = startPosition.y + Mathf.Sin(Time.time * moveSpeed) * moveHeight;
        transform.position = new Vector3(startPosition.x, newY, startPosition.z);
        transform.Rotate(Vector3.up * Time.deltaTime * 20f);
    }
}
