using UnityEngine;

public class OrbitCamera : MonoBehaviour
{
    public Transform target;
    public float rotationSpeed = 50f;

    float worldY;
    float radiusXZ;
    float angle;

    void Start()
    {
        if (!target) return;

        worldY = transform.position.y;

        Vector3 toCam = transform.position - target.position;
        Vector3 h = new Vector3(toCam.x, 0f, toCam.z);
        radiusXZ = h.magnitude;

        if (radiusXZ < 1e-3f) radiusXZ = 0.001f;

        angle = Mathf.Atan2(h.z, h.x);
    }

    void Update()
    {
        if (!target) return;

        angle += rotationSpeed * Mathf.Deg2Rad * Time.deltaTime;

        Vector3 dirXZ = new Vector3(Mathf.Cos(angle), 0f, Mathf.Sin(angle));

        Vector3 pos = target.position + dirXZ * radiusXZ;
        pos.y = worldY;

        transform.position = pos;
        transform.LookAt(target.position);
    }
}
