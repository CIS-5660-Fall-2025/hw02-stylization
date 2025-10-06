using System.Linq;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class MaterialToggle : MonoBehaviour
{
    public Material[] materials;
    public FullScreenPassRendererFeature screenRenderer;
    int index;

    void Start()
    {
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            index = (index + 1) % materials.Count();
            SwapToNextMaterial(index);
        }
    }

    void SwapToNextMaterial(int index)
    {
        screenRenderer.passMaterial = materials[index % materials.Count()];
    }
}