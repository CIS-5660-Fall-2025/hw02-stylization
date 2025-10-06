using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class changeMat : MonoBehaviour
{
    public Material[] materials;
    private MeshRenderer meshRenderer;
    int index;

    void Start() {
        meshRenderer = GetComponent<MeshRenderer>();
    }

    void Update() {
        if (Input.GetKeyDown(KeyCode.Space)) {
            index = (index + 1) % materials.Count();
            SwapToNextMaterial(index);
        }
    }

    void SwapToNextMaterial(int index) {
        meshRenderer.material = materials[index % materials.Count()];
    }
}
