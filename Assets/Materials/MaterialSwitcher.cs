using UnityEngine;

public class MaterialSwitcher : MonoBehaviour
{
    [Header("Assign two materials here")]
    public Material defaultMaterial;   
    public Material glowMaterial;      

    private MeshRenderer meshRenderer;
    private bool glowing = false;

    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        if (meshRenderer && defaultMaterial)
            meshRenderer.material = defaultMaterial;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            glowing = !glowing;
            meshRenderer.material = glowing ? glowMaterial : defaultMaterial;
        }
    }
}
