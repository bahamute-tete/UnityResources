
using UnityEngine;
using static UnityEngine.Mathf;

public static class EasingTools
{

    const float pi = 3.1415926f;

    public delegate float EaseFunction(float t);
    static EaseFunction[] functions = { Linear , SmoothStart, SmoothStart2,SmoothStop, SmoothStop2, OutBounce };
    public enum EasyType { Linear, SmoothStart, SmoothStart2, SmoothStop, SmoothStop2, OutBounce };

    public static EaseFunction GetFunction(EasyType name) => functions[(int)name];

    public static float Linear(float t) => t;
    public static float SmoothStart(float t) => t * t ;
    public static float SmoothStart2(float t) => t * t * t;
    public static float SmoothStop(float t) => 1 - (1 - t) * (1 - t);
    public static float SmoothStop2(float t) => 1 - (1 - t) * (1 - t)* (1 - t);
    public static float OutBounce(float t)
    {
        float n1 = 7.5625f;
        float d1 = 2.75f;

        if (t < 1 / d1)
        {
            return n1 * t * t;
        }
        else if (t < 2 / d1)
        {
            return n1 * (t -= 1.5f / d1) * t + 0.75f;
        }
        else if (t < 2.5f / d1)
        {
            return n1 * (t -= 2.25f / d1) * t + 0.9375f;
        }
        else
        {
            return n1 * (t -= 2.625f / d1) * t + 0.984375f;
        }
    }

}

