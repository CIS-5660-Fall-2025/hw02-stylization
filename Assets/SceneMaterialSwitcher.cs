using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            // TODO: Switch
        }
    }
}
