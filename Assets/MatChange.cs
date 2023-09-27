using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MatChange : MonoBehaviour
{

    [SerializeField] Material mat0,mat1;
    // Start is called before the first frame update
    void Start()
    {

        Material[] newMats = GetComponent<Renderer>().materials;
        newMats[0] = mat0;
        newMats[1] = mat1;

        GetComponent<Renderer>().materials = newMats;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
