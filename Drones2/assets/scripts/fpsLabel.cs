using Godot;
using System;

public partial class fpsLabel : Label
{
    public override void _Process(double delta)
    {
        Text = $"FPS: {Engine.GetFramesPerSecond()}";
    }
}
