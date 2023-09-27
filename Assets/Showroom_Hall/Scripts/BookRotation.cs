using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BookRotation : MonoBehaviour
{
   
    float angle = 0;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        angle += 1f;

        transform.rotation = Quaternion.Euler(0, angle, 0);
    }
}
