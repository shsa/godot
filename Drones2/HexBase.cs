using Godot;
using System;

public partial class HexBase : MeshInstance3D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		var cylinderMesh = new CylinderMesh();
		cylinderMesh.TopRadius = 1.0f;
		cylinderMesh.BottomRadius = 1.0f;
		cylinderMesh.Height = 2.0f;
		cylinderMesh.RadialSegments = 6;
		cylinderMesh.Rings = 2;
		Mesh = cylinderMesh;
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
