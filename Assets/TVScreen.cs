using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TVScreen : MonoBehaviour
{
    [SerializeField] Color[] screenColors;

    void Start()
    {
        var renderer = GetComponent<MeshRenderer>();
        var propBlock = new MaterialPropertyBlock();
        renderer.GetPropertyBlock(propBlock);
        propBlock.SetColor("_InnerColor", screenColors[Random.Range(0, screenColors.Length)]);
        //propBlock.SetColor("_InnerColor", Color.HSVToRGB(Random.Range(-0.2f, 0.2f) + 5f/6f, .68f, 1f));
        renderer.SetPropertyBlock(propBlock);
    }
}
