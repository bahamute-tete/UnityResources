using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(LerpAnim))]
public class AnimLerpEventCast : MonoBehaviour
{
    LerpAnim reciver => GetComponent<LerpAnim>();
    [SerializeField]LerpAnim eventCaster;

    //public enum EventOrder {EndAnim=0, BeforAnim }
    //[SerializeField] EventOrder eventOrder;

    private void OnEnable()
    {
        eventCaster.OnAnimStop += Action;
    }

    private void OnDisable()
    {
        eventCaster.OnAnimStop += Action;
    }

    // Update is called once per frame
    void Action()
    {
        reciver.Active();
    }
}
