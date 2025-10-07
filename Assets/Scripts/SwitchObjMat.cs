using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class SwitchObjMat : MonoBehaviour
{
    [Header("Material Sets")]
    public Material[] materialsSetA;
    public Material[] materialsSetB;

    private MeshRenderer meshRenderer;
    private bool usingSetA = true;

    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        if (materialsSetA != null && materialsSetA.Length > 0)
            meshRenderer.materials = materialsSetA;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            if (usingSetA)
                meshRenderer.materials = materialsSetB;
            else
                meshRenderer.materials = materialsSetA;

            usingSetA = !usingSetA;
        }
    }
}


