using Godot;
using System;
using System.Diagnostics;

public partial class main : Node3D
{
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		var mesh = ResourceLoader.Load<Mesh>("res://assets/models/hex.obj");
		var mm = new MultiMesh();
		mm.TransformFormat = MultiMesh.TransformFormatEnum.Transform3D;
		mm.InstanceCount = 100;
		mm.Mesh = mesh;

		for (int i = 0; i < mm.InstanceCount; i++)
		{
			var transform = new Transform3D();
			transform.Origin = new Vector3(GD.RandRange(-10, 10), 0, GD.RandRange(-10, 10));
			mm.SetInstanceTransform(i, transform);
		}

		var mmi = new MultiMeshInstance3D();
		mmi.Multimesh = mm;
		AddChild(mmi);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
