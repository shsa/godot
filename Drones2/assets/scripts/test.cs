using Godot;
using System;

public partial class test : Node3D
{
    public override void _Process(double delta)
    {
        DebugDraw.DrawLine(new Vector3(0, 0, 0), new Vector3(0, 100, 0));
    }
}
