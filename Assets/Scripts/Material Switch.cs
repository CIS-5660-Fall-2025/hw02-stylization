using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialSwitch : MonoBehaviour
{
    private MeshRenderer Renderer;
    private bool Swapped = false;
    private Material m1;
    private Material m2;
    private static float LastTime = 0.0f;
    private float LocalLastTime = 0.0f;
    private static Color Col1;
    private static Color Col2;
    private static Color Col3;
    private static float Threshold1;
    private static float Threshold2;

    // Start is called before the first frame update
    void Start()
    {
        Renderer = GetComponent<MeshRenderer>();
        m1 = Resources.Load<Material>("Default");
        m2 = Resources.Load<Material>("Default 2");
    }

    // Update is called once per frame
    void Update()
    {
        if (Swapped && Time.time - LastTime > 0.5f)
        {
            float l3 = Random.value * 0.4f + 0.5f;
            float l2 = l3 + Random.value * 0.4f * (1f - l3);
            float l1 = l2 + Random.value * (1f - l2);

            float cDir = Random.value > 0.5f ? -1f : 1f;

            float c1 = Random.value * 0.05f + 0.05f;
            float c2 = c1 + Random.value * 0.025f * cDir;
            float c3 = c2 + Random.value * 0.025f * cDir;

            float hDir = Random.value > 0.5f ? -1f : 1f;

            float h1 = Random.value * Mathf.PI * 2f;
            float h2 = h1 + (Random.value * Mathf.PI * 2f) * 0.35f * hDir;
            float h3 = h2 + (Random.value * Mathf.PI * 2f) * 0.35f * hDir;

            float threshold1 = Random.value;
            float threshold2 = 1 - Random.value * (1 - threshold1);

            Col1 = Oklch(l1, c1, h1);
            Col2 = Oklch(l2, c2, h2);
            Col3 = Oklch(l3, c3, h3);
            Threshold1 = threshold1;
            Threshold2 = threshold2;

            LastTime = Time.time;
        }

        if (Swapped && LocalLastTime != LastTime)
        {
            LocalLastTime = LastTime;

            Renderer.material.SetColor("_Highlight", Col1);
            Renderer.material.SetColor("_Midtone", Col2);
            Renderer.material.SetColor("_Shadow", Col3);
            Renderer.material.SetVector("_Thresholds", new Vector2(Threshold1, Threshold2));
        }

        if (!Input.GetKeyDown(KeyCode.Space)) return;

        Renderer.material = Swapped ? m1 : m2;
        LastTime = Time.time;

        Swapped = !Swapped;
    }

    private Color Oklch(float l, float c, float h)
    {
        float oklabA = c * Mathf.Cos(h);
        float oklabB = c * Mathf.Sin(h);

        float lmsL = l + 0.3963377774f * oklabA + 0.2158037573f * oklabB;
        float lmsM = l - 0.1055613458f * oklabA - 0.0638541728f * oklabB;
        float lmsS = l - 0.0894841775f * oklabA - 1.2914855480f * oklabB;

        float lmsL3 = lmsL * lmsL * lmsL;
        float lmsM3 = lmsM * lmsM * lmsM;
        float lmsS3 = lmsS * lmsS * lmsS;

        float linR = 4.076741f * lmsL3 - 3.307711f * lmsM3 + 0.2309699f * lmsS3;
        float linG = -1.268438f * lmsL3 + 2.609757f * lmsM3 - 0.3413193f * lmsS3;
        float linB = -0.004196086f * lmsL3 - 0.7034186f * lmsM3 + 1.707614f * lmsS3;

        return new Color(SrgbGamma(linR), SrgbGamma(linG), SrgbGamma(linB));
    }

    private static float SrgbGamma(float linear) => linear <= 0.0031308f
        ? 12.92f * linear
        : 1.055f * Mathf.Pow(linear, 1f / 2.4f) - 0.055f;
}
