using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Raycaster : MonoBehaviour
{
    Camera camera;
    void Start() {
        camera = GetComponent<Camera>();
    }

    void Update() {
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = camera.ScreenPointToRay(Input.mousePosition);

            RaycastHit hit;
            bool hitObject = Physics.Raycast(ray, out hit);
            if (hitObject)
            {
                Debug.Log(hit.collider.gameObject.name);
            }
        }
    }
}
