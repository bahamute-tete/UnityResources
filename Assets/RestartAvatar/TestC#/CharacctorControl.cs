using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class CharacctorControl : MonoBehaviour
{
    Animator animator;
    [SerializeField]Animator hairAnimator;
    CustomCharactor hairTest;
    [SerializeField]GameObject testHair = null;
    
    
    // Start is called before the first frame update
    void Start()
    {
        animator = GetComponent<Animator>();
        hairTest = GetComponent<CustomCharactor>();
    }

    // Update is called once per frame
    void Update()
    {
        //testHair = hairTest.hair;

        if (testHair.tag.Equals("TestHair"))
        {
            hairAnimator = testHair.GetComponent<Animator>();
        }
        else
        {
            hairAnimator = null;
        }


        var keyboard = Keyboard.current;
        if (keyboard.spaceKey.wasPressedThisFrame)
        {
            animator.SetTrigger("Jump");

            if (hairAnimator)
            {
                hairAnimator.SetTrigger("Jump");
            }
        }

        if (keyboard.eKey.wasPressedThisFrame)
        {
            animator.SetTrigger("Greet");
            if (hairAnimator)
            {
                hairAnimator.SetTrigger("Greet");
            }
        }


    }

    public void Movement(InputAction.CallbackContext ctx)
    {
        Vector2 value = ctx.ReadValue<Vector2>();
        animator.SetFloat("Speed", value.magnitude);

        if (hairAnimator)
        {
            hairAnimator.SetFloat("Speed", value.magnitude);
        }

        Vector3 dir = new Vector3(value.x, transform.forward.y, value.y);
        transform.forward = dir;
    }
}
