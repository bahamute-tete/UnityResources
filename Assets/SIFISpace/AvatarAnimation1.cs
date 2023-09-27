using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using CMF;
using UnityEngine.Events;

public class AvatarAnimation1 : MonoBehaviour
{
    
    [SerializeField]AdvancedWalkerController controller;
    [SerializeField] Animator animator;
    bool _isGrounded;

    private float currentMoveSpeed;

    // Start is called before the first frame update
    void Start()
    {
        currentMoveSpeed = controller.movementSpeed;
    }

    // Update is called once per frame
    void FixedUpdate()
    {

        Vector3 _velocity = controller.GetVelocity();
        float speed = _velocity.magnitude;
        if (Input.GetKey(KeyCode.LeftShift))
        {
            speed = Mathf.Clamp(speed, 0, 1f);
            controller.movementSpeed = currentMoveSpeed;
        }
        else
        {
            speed = Mathf.Clamp(speed, 0, 0.3f);
            controller.movementSpeed = currentMoveSpeed*0.5f;
        }
        _isGrounded = controller.IsGrounded();
    
        animator.SetBool("IsGrounded", _isGrounded);

        if (_velocity.y < 0.01f && _isGrounded)
        {
            animator.SetFloat("Speed",speed);
        }

        if (Input.GetKeyDown(KeyCode.E))
        {
            animator.SetTrigger("Greet");
        }
    }

    void OnJump(Vector3 _v)
    {
        animator.SetTrigger("OnJump");
    }

    void OnLand(Vector3 _v)
    {
        animator.SetTrigger("OnLand");
    }
}
