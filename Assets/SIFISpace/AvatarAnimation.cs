using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using CMF;

public class AvatarAnimation : MonoBehaviour
{

    public AdvancedWalkerController controller;
    public Animator animator;
    // Start is called before the first frame update
    void Start()
    {
        controller = GetComponent<AdvancedWalkerController>();
        animator = GetComponentInChildren<Animator>();

        controller.OnLand += OnLand;
        controller.OnJump += OnJump;
    }

    // Update is called once per frame
    void Update()
    {

        animator.SetTrigger("OnLand");
        Vector3 _velocity = controller.GetVelocity();

        bool _isGrounded = controller.IsGrounded();
        animator.SetBool("IsGrounded", _isGrounded);

        if (_velocity.y < 0.01f)
            animator.SetFloat("Speed", _velocity.magnitude);
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
}
