using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WhirlipedeRotate : MonoBehaviour
{
    private bool toggle = false;
    [SerializeField] public Material[] materials;
    private MeshRenderer meshRenderer;
    int index = 0;
    [SerializeField] private float rotationAmount = -0.5f;

    // Start is called before the first frame update
    void Start()
    {
        MeshRenderer[] allRenderers = GetComponentsInChildren<MeshRenderer>();
        meshRenderer = allRenderers[0];
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space) && materials.Length > 0)
        {
            index = (index + 1) % materials.Length;
            SwapToNextMaterial(index);
            toggle = !toggle;
        }

        if (toggle)
        {
            transform.Rotate(Vector3.right, rotationAmount, Space.Self);
        }
    }

    void SwapToNextMaterial(int index)
    {
        meshRenderer.material = materials[index % materials.Length];
    }
}
