using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractionScreen : MonoBehaviour
{
    public Material[] materials;
//     private MeshRenderer meshRenderer;
    int index;
    public FullScreenFeature screenFeature;

    void Start () {
        if (screenFeature != null) {
                screenFeature.settings.material = materials[0];
        }
    }

    void Update () {
            if (Input.GetKeyDown(KeyCode.Space)){
                    index = (index + 1) % materials.Length;
                    SwapToNextMaterial(index);
            }
    }

    void SwapToNextMaterial (int index) {
        if (screenFeature != null) {
            screenFeature.settings.material = materials[index % materials.Length];
        }
    }
}


