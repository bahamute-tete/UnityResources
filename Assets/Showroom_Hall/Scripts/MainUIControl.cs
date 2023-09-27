using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MainUIControl : MonoBehaviour
{
    [SerializeField] Button quitBtn;

    bool isShow= false;
    // Start is called before the first frame update
    void Start()
    {
        quitBtn.transform.gameObject.SetActive(isShow);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            isShow= !isShow;
            quitBtn.transform.gameObject.SetActive(isShow);

        }

    }
}
