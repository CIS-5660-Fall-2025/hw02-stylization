using System.Collections;
using System.Collections.Generic;
using Render_Settings.Render_Features;
using UnityEngine;

public class Interaction : MonoBehaviour
{
    public Material[] materials;
    [SerializeField] FullScreenPassRendererFeature moebiusFeature;
    
    [SerializeField] float[] outlineWidths;
    [SerializeField] EdgeDetectionFeature edgeFeature;
    MeshRenderer meshRenderer;
    int matIndex;
    int outlineWidthIdx;

    void Start () {
        meshRenderer = GetComponent<MeshRenderer>();
    }

    void Update () {
        if (Input.GetKeyDown(KeyCode.Space)){
            matIndex = (matIndex + 1) % materials.Length;
            outlineWidthIdx = (outlineWidthIdx + 1) % outlineWidths.Length;
            SwapToNextMaterial(matIndex);
            SwapToNextOutlinewidth(outlineWidthIdx);
        }
    }

    void SwapToNextMaterial (int index) {
        //meshRenderer.material = materials[index % materials.Length];
        moebiusFeature.passMaterial = materials[index % materials.Length];
        //edgeFeature.settings.outlineThickness = outlineWidths[index % outlineWidths.Length];
    }
    
    void SwapToNextOutlinewidth (int index) {
        //meshRenderer.material = materials[index % materials.Length];
        //moebiusFeature.passMaterial = materials[index % materials.Length];
        edgeFeature.settings.outlineThickness = outlineWidths[index % outlineWidths.Length];
    }
}
