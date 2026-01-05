using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[CreateAssetMenu(fileName = "MyBlurSettings", menuName = "Rendering/MyBlur Settings")]
public class BlurSettings : ScriptableObject
{
    [Header("Blur Settings")]
    public float down_scale;
    public float Up_scale;
    public float radius;
    public int iteration;
}
