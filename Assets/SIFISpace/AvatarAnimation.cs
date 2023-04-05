using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using CMF;
using UnityEngine.Events;

public class AvatarAnimation : MonoBehaviour
{
    
    [SerializeField]AdvancedWalkerController controller;
    [SerializeField] Animator animator, animator2, animator3, animator4;
    bool _isGrounded;

    public UnityEvent unityEvent;


    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

        //animator.SetTrigger("OnLand");
        Vector3 _velocity = controller.GetVelocity();
       

        _isGrounded = controller.IsGrounded();
      

        animator.SetBool("IsGrounded", _isGrounded);
        animator2.SetBool("IsGrounded", _isGrounded);
        animator3.SetBool("IsGrounded", _isGrounded);
        animator4.SetBool("IsGrounded", _isGrounded);

        if (_velocity.y < 0.01f && _isGrounded)
        {
            animator.SetFloat("Speed", _velocity.magnitude);
            animator2.SetFloat("Speed", _velocity.magnitude);
            animator3.SetFloat("Speed", _velocity.magnitude);
            animator4.SetFloat("Speed", _velocity.magnitude);
        }

        if (Input.GetKeyDown(KeyCode.P))
        {
            animator.SetTrigger("Greet");
            animator2.SetTrigger("Greet");
            animator3.SetTrigger("Greet");
            animator4.SetTrigger("Greet");

            StartCoroutine(ShowScene(2));
           
        }
     
    }

    void OnJump(Vector3 _v)
    {
        //React to event by playing audio clip, animations, [...]
        animator.SetTrigger("OnJump");
    }

    void OnLand(Vector3 _v)
    {
        //Set animation trigger;
        animator.SetTrigger("OnLand");
  
    }


    IEnumerator ShowScene(float time)
    {
        yield return new WaitForSeconds(time);
        unityEvent.Invoke();
    }

}
