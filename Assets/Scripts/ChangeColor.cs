using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeColor : MonoBehaviour
{
    [SerializeField] private Renderer targetRenderer; // object whose material will change
    [SerializeField] private List<Material> partyMaterials; // list of materials for party mode
    [SerializeField] private float changeInterval = 0.5f; // seconds between material swaps

    private int currentIndex = 0;
    private float timer = 0f;

    void Start()
    {
        if (targetRenderer == null)
            targetRenderer = GetComponent<Renderer>();

        if (partyMaterials.Count > 0)
            targetRenderer.material = partyMaterials[0];
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            SwapToNextMaterial(currentIndex);
        }

        
    }

    private void SwapToNextMaterial(int index)
    {
        if (partyMaterials.Count == 0) return;
        currentIndex = (currentIndex + 1) % partyMaterials.Count;
        targetRenderer.material = partyMaterials[currentIndex];
    }
}
