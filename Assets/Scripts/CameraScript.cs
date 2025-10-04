using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraScript : MonoBehaviour
{
    [SerializeField] Transform gem;
    [SerializeField] float moveDuration, moveDistance;
    Vector3 gemPos;

    private Transform cam;

    // Start is called before the first frame update
    void Start()
    {
        transform.LookAt(gem);
        gemPos = gem.position;
        cam = transform.GetChild(0);
    }

    public void ShakeCam() {
        StartCoroutine(CamShakeCoroutine());
    }

    public void MoveAway() {
        StartCoroutine(MoveAwayCoroutine());
    }

    private IEnumerator MoveAwayCoroutine()
    {
        float duration = moveDuration;
        float distance = moveDistance;

        Vector3 startPos = transform.position;
        float elapsed = 0f;

        while (elapsed < moveDuration)
        {
            float t = elapsed / moveDuration;
            t = Mathf.SmoothStep(0f, 1f, t);

            Vector3 dir = (transform.position - gemPos);
            dir.y = 0f;
            dir.Normalize();

            Vector3 targetPos = gemPos + dir * moveDistance;
            transform.position = Vector3.Lerp(startPos, targetPos, t);

            transform.LookAt(gemPos);

            elapsed += Time.deltaTime;
            yield return null;
        }
    }

    private IEnumerator CamShakeCoroutine() {
        Vector3 originalPos = Vector3.zero;
        float elapsed = 0f;
        float duration = 0.9f;

        while (elapsed < duration)
        {
            float t = elapsed / duration;
            float currentMagnitude = Mathf.Lerp(0.08f, 0f, Mathf.SmoothStep(0f, 1f, t));

            Vector3 randomOffset = Random.insideUnitSphere * currentMagnitude;
            randomOffset.x *= 0.5f;

            cam.localPosition = originalPos + randomOffset;

            elapsed += 0.04f;
            yield return new WaitForSeconds(0.04f);
        }

        cam.localPosition = originalPos;
    }
}