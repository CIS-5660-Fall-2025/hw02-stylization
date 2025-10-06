using System.Collections;
using System.Collections.Generic;
using UnityEngine.Rendering.Universal;
using UnityEngine;
using System.Linq;

public class ToggleRendererFeature : MonoBehaviour
{
    public ScriptableRendererFeature featureToToggle;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.C))
        {
            if (featureToToggle != null)
            {
                featureToToggle.SetActive(!featureToToggle.isActive);
            }
        }
    }
}
