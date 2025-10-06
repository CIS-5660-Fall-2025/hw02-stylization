using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ToggleMaterial : MonoBehaviour
{
    // Start is called before the first frame update
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
            meshRenderer.material = materials[index % materials.Length];
    }
}

