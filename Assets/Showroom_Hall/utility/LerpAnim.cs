using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LerpAnim : MonoBehaviour
{
    public delegate void AnimStop();
    public event AnimStop OnAnimStop;
    public delegate void AnimStart();
    public event AnimStop OnAnimStrat;


    bool isPlay = false;
    public bool reverse;
    [SerializeField] GameObject obj;
    public float duration;
    float t = 0;
    public EasingTools.EasyType easyType;
    public enum Property {Position=0,Rotaion,LocalScale ,AnchorPos,SizeDelta }
    public Property property;

     public Vector3 property1, property2;
     Vector3 resPro;

    private void Start()
    {
        switch (property)
        {
            case Property.Position:
                obj.transform.position = property1;
                break;

            case Property.LocalScale:
                obj.transform.localScale = property1;
                break;

            case Property.Rotaion:
                obj.transform.rotation = Quaternion.Euler(property1);
                break;

            case Property.AnchorPos:
                if (!GetComponent<RectTransform>())
                {
                    obj.AddComponent<RectTransform>();
                }
                obj.GetComponent<RectTransform>().anchoredPosition = property1;
                break;

            case Property.SizeDelta:
                if (!GetComponent<RectTransform>())
                {
                    obj.AddComponent<RectTransform>();
                }
                obj.GetComponent<RectTransform>().sizeDelta = property1;
                break;
        }
    }

    // Update is called once per frame
    void Update()
    {
        float delta = Time.deltaTime / duration;
   

        if (isPlay)
        {
            OnAnimStrat?.Invoke();

            t += delta;
           
            if (!reverse)
            {
                resPro = Vector3.Lerp(property1, property2, EasingTools.GetFunction(easyType)(t));
            }
            else
            {
                resPro = Vector3.Lerp(property2, property1, EasingTools.GetFunction(easyType)(t));
            }

            switch (property)
            {
                case Property.Position:
                    obj.transform.position = resPro;
                    break;

                case Property.LocalScale:
                    obj.transform.localScale = resPro;
                    break;

                case Property.Rotaion:
                    obj.transform.rotation = Quaternion.Euler(resPro);
                    break;

                case Property.AnchorPos:
                    if (!GetComponent<RectTransform>())
                    {
                        obj.AddComponent<RectTransform>();
                    }
                    obj.GetComponent<RectTransform>().anchoredPosition =resPro;
                    break;

                case Property.SizeDelta:
                    if (!GetComponent<RectTransform>())
                    {
                        obj.AddComponent<RectTransform>();
                    }
                    obj.GetComponent<RectTransform>().sizeDelta = resPro;
                    break;
            }

            if (Mathf.Clamp01(t) == 1)
            {
                t = 0;
                isPlay = false;
                reverse = !reverse;
                resPro = (reverse) ? property2 : property1;

                switch (property)
                {
                    case Property.Position:
                        obj.transform.position = resPro;
                        break;

                    case Property.LocalScale:
                        obj.transform.localScale = resPro;
                        break;

                    case Property.Rotaion:
                        obj.transform.rotation = Quaternion.Euler(resPro);
                        break;

                    case Property.AnchorPos:
                        if (!GetComponent<RectTransform>())
                        {
                            obj.AddComponent<RectTransform>();
                        }
                        obj.GetComponent<RectTransform>().anchoredPosition = resPro;
                        break;

                    case Property.SizeDelta:
                        if (!GetComponent<RectTransform>())
                        {
                            obj.AddComponent<RectTransform>();
                        }
                        obj.GetComponent<RectTransform>().sizeDelta = resPro;
                        break;
                }

                OnAnimStop?.Invoke();
            }
        }

        
    }
    public void Active()
    {
        isPlay = true;
    }
}
