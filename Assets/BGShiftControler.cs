using UnityEngine;

public class BGShiftController : MonoBehaviour
{
    public float shiftStep = -0.0004f;
    private Material mat;

    void Start()
    {
        mat = GetComponent<Renderer>().material;
    }

    void Update()
    {
        if (Input.GetKey(KeyCode.B))
        {
            float current = mat.GetFloat("_BGShift");
            mat.SetFloat("_BGShift", current + shiftStep);
        }
    }
}
