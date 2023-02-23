using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotatCircle : MonoBehaviour
{
    public bool CCW = true;
    public float speed = 1.0f;
    Vector3 angle;
    // Start is called before the first frame update
    void Start()
    {
         angle = transform.rotation.eulerAngles;
    }

    // Update is called once per frame
    void Update()
    {
        var dir = CCW ? 1f : -1f;
        angle += new Vector3(0, dir*Time.deltaTime * speed, 0);
        transform.rotation = Quaternion.Euler(angle);
    }
}
