using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DayNightToggle : MonoBehaviour
{
    public Light directionalLight;
    public Material paperOverlayMaterial;

    private bool isDay = true;

    void Start()
    {
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            isDay = !isDay;
            ToggleLighting();
        }
    }

    void ToggleLighting()
    {
        if (isDay)
        {
            directionalLight.color = Color.white;
            directionalLight.intensity = 1f;
            paperOverlayMaterial.SetColor("_SkyColor", new Color(0.49f, 0.85f, 0.92f, 1.0f));
            paperOverlayMaterial.SetColor("_IsDay", new Color(1.0f,1.0f,1.0f,1.0f));
        }
        else
        {
            directionalLight.color = new Color(0.69f, 0.71f, 1.0f);
            directionalLight.intensity = 0.5f;
            paperOverlayMaterial.SetColor("_SkyColor", new Color(0.0f, 0.0f, 0.0f, 0.0f));
            paperOverlayMaterial.SetColor("_IsDay", new Color(0.09f, 0.45f, 0.82f, 1.0f));
        }
    }

}
