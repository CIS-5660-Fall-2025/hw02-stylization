using UnityEngine;

public class PostProcessToggle : MonoBehaviour
{
    public Material postProcessMaterial;
    private bool showingSmoke = true;
    
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            showingSmoke = !showingSmoke;
            
            // Just toggle EffectBlend between 0 and 1
            // This automatically switches both mask AND color
            float targetValue = showingSmoke ? 0.0f : 1.0f;
            postProcessMaterial.SetFloat("_EffectBlend", targetValue);
            
            Debug.Log(showingSmoke ? "Showing Smoke" : "Showing Vignette");
        }
    }
}