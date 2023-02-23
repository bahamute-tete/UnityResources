
using UnityEngine;
using UnityEngine.UI;

public class CameraControl : MonoBehaviour
{

    public Transform target;
    private float xSpeed = 100;
    private float ySpeed = 50;
    public float yMin = -90;
    public float yMax = 90;
    public bool needDamping = true; 
    private float damping = 5; 
    private float x = 0;
    private float y = 0;
    private Vector3 initialAngle = new Vector3(0, 0, 0);

    [SerializeField]
    Button resetCamera;

    bool inputContact;

    void Start()
    {
        //Vector3 angles = transform.eulerAngles;
        initialAngle = transform.eulerAngles;
        x = initialAngle.y;
        y = initialAngle.x;


        if (resetCamera)
        {
            resetCamera.onClick.AddListener(delegate {

                x = initialAngle.y;
                y = initialAngle.x;

            });
        }
       
    }
    void LateUpdate()
    {
        if (target)
        {
            if (Input.GetMouseButton(1))
            {
                x += Input.GetAxis("Mouse X") * xSpeed * 0.02f;
                y -= Input.GetAxis("Mouse Y") * ySpeed * 0.02f;
                y = ClampAngle(y, yMin, yMax);

            }
                Quaternion rotation = Quaternion.Euler(y, x, 0.0f);
                Vector3 disVector = new Vector3(0.0f, 0.0f, 0);
                Vector3 position = rotation * disVector + target.position;

                if (needDamping)
                {
                    transform.rotation = Quaternion.Lerp(transform.rotation, rotation, Time.deltaTime * damping);
                    transform.position = Vector3.Lerp(transform.position, position, Time.deltaTime * damping);
                }
                else
                {
                    transform.rotation = rotation;
                    transform.position = position;
                }

            
        }

       
        
       
    }

    private float ClampAngle(float angle, float min, float max)
    {
        if (angle < -360)
            angle += 360;
        if (angle > 360)
            angle -= 360;
        return Mathf.Clamp(angle, min, max);
    }

}
