using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GemScript : MonoBehaviour
{
    [SerializeField] Transform gemModel;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float newY = transform.position.y + Mathf.Sin(Time.time * 0.8f) * 0.16f;

        gemModel.position = new Vector3(0, newY, 0);
    }
}
