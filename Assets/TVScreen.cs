using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TVScreen : MonoBehaviour
{
    void Start()
    {
        var renderer = GetComponent<MeshRenderer>();
        var propBlock = new MaterialPropertyBlock();
        renderer.GetPropertyBlock(propBlock);
        propBlock.SetFloat("_TestParam", UnityEngine.Random.Range(0f, 1f));
        renderer.SetPropertyBlock(propBlock);
    }
}
