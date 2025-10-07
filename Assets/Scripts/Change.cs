using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using static UnityEngine.Rendering.DebugUI;

public class Change : MonoBehaviour
{
    public Material cloudsMaterial;
    public Material outlinesMaterial;


    public Material[] materials;
    private MeshRenderer meshRenderer;
    private string property = "_mode";
    private string speedProp = "_Speed";
    int index;

    // Start is called before the first frame update
    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            index = (index + 1) % materials.Length;
            SwapToNextMaterial(index);

            if (cloudsMaterial.GetFloat(property) == 0.0f)
            {
                cloudsMaterial.SetFloat(property, 1.0f);
                cloudsMaterial.SetFloat(speedProp, 1.0f);
            }
            else
            {
                cloudsMaterial.SetFloat(property, 0.0f);
                cloudsMaterial.SetFloat(speedProp, 20.0f);
            }

            if (outlinesMaterial.GetFloat(property) == 0.0f)
            {
                outlinesMaterial.SetFloat(property, 1.0f);
            }
            else
            {
                outlinesMaterial.SetFloat(property, 0.0f);
            }
        }
    }

    void SwapToNextMaterial(int index)
    {
        meshRenderer.material = materials[index % materials.Length];
    }

    public void ResetAll()
    {
        cloudsMaterial.SetFloat(property, 0.0f);
        outlinesMaterial.SetFloat(property, 0.0f);
    }
    void OnDisable()
    {
        ResetAll();
    }

    void OnDestroy()
    {
        ResetAll();
    }
}
