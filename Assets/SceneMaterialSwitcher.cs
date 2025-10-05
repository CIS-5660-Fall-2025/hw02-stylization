using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class SceneMaterialSwitcher : MonoBehaviour
{
    // Pinkish Purplish, PostProcess goes to Blue a Bit
    [SerializeField] Material tvBodyMaterial1;
    [SerializeField] Material outlineMaterial1;
    [SerializeField] Material postProcessMaterial1;

    // Redish Purplish Refuge, PostProcess goes to Refuge yellow or purple??
    [SerializeField] Material tvBodyMaterial2;
    [SerializeField] Material outlineMaterial2;
    [SerializeField] Material postProcessMaterial2;

    //
    [SerializeField] UniversalRendererData rendererData;

    [SerializeField] bool refugeMode;

    [SerializeField] GameObject[] Televisions;

    void UpdateMaterials()
    {
        foreach (var tv in Televisions)
        {
            foreach (var childRenderer in tv.GetComponentsInChildren<MeshRenderer>())
            {
                if (childRenderer.gameObject.name != "tv_glass_ekran")
                    childRenderer.material = refugeMode ? tvBodyMaterial2 : tvBodyMaterial1;
            }
        }

        foreach (var feature in rendererData.rendererFeatures)
        {
            if (feature.name == "OutlineFeature")
            {
                FullScreenFeature outlineFeature = feature as FullScreenFeature;
                outlineFeature.ExposedSettings.material = refugeMode ? outlineMaterial2 : outlineMaterial1;
            }

            if (feature.name == "PostProcessFeature")
            {
                FullScreenFeature postProcessFeature = feature as FullScreenFeature;
                postProcessFeature.ExposedSettings.material = refugeMode ? postProcessMaterial2 : postProcessMaterial1;
            }
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            refugeMode = !refugeMode;
            UpdateMaterials();
        }
    }
}
