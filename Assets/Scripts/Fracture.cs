using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Fracture : MonoBehaviour
{
    [SerializeField] private float explosionForce;
    [SerializeField] private float scaleSpeed = 0.5f;
    public GameObject originalObj;
    public GameObject fracturedObj;

    private GameObject fractObj;

    public void FractureObject()
    {
        originalObj.SetActive(false);
        if (fracturedObj == null) return;
        fracturedObj.SetActive(true);
        foreach(Transform t in fracturedObj.transform) {
            var rb = t.GetComponent<Rigidbody>();
            rb.AddExplosionForce(explosionForce, originalObj.transform.position, 2);
            StartCoroutine(Shrink(t, 2f));
        }
        Destroy(this.gameObject, 8);
    }

    private IEnumerator Shrink(Transform t, float delay) {
        
        yield return new WaitForSeconds(delay);
        t.gameObject.GetComponent<Collider>().enabled = false;
        Vector3 newScale = t.localScale;
        while (newScale.x > 0.01f) {
            newScale -= scaleSpeed * new Vector3(1, 1, 1);
            if (t == null) break;
            t.localScale = newScale;
            yield return new WaitForSeconds(0.05f);
        }
    }
}
