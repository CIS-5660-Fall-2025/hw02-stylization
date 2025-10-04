using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GemScript : MonoBehaviour
{
    [SerializeField] Transform gemModel;
    private bool returnToOriginal;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (returnToOriginal) return;

        float newY = transform.position.y + Mathf.Sin(Time.time * 0.8f) * 0.16f;

        gemModel.position = new Vector3(0, newY, 0);
    }

    public void StopOsc() {
        returnToOriginal = true;
        StartCoroutine(ReturnToStartPos());
    }
    
    private IEnumerator ReturnToStartPos() {
        Vector3 currentPos = gemModel.position;
        Vector3 currentEuler = gemModel.eulerAngles;

        float elapsed = 0f;
        float duration = 4;

        while (elapsed < duration)
        {
            float t = elapsed / duration;
            t = Mathf.SmoothStep(0f, 1f, t);

            gemModel.position = Vector3.Lerp(currentPos, transform.position, t);

            float newX = Mathf.LerpAngle(currentEuler.x, 0f, t);
            gemModel.rotation = Quaternion.Euler(newX, currentEuler.y, currentEuler.z);

            elapsed += Time.deltaTime;
            yield return null;
        }
    }
}
