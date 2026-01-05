using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class ColorTint : VolumeComponent
{
    public ColorParameter color =  new ColorParameter(Color.white,true);
}
