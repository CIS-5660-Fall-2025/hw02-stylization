using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeMyMat : MonoBehaviour
{
    public Material[] materials;
    private MeshRenderer meshRenderer;
    int index;

    void Start () {
        meshRenderer = GetComponent<MeshRenderer>();
    }

    void Update () {
        if (Input.GetKeyDown(KeyCode.Space)){
            index = (index + 1) % materials.Length;
            SwapToNextMaterial(index);
        }
    }

    void SwapToNextMaterial (int index) {
        if (this.GetComponent<Terrain>())
        {
            this.GetComponent<Terrain>().materialTemplate = materials[index];
        }
        else
        {
            meshRenderer.material = materials[index % materials.Length];   
        }
    }
}
