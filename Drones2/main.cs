using Godot;
using System;
using System.Diagnostics;

public partial class main : Node3D
{
	[Export]
	public MeshInstance3D meshInstance { get; set; }

	[Export]
	public HexGridView GridView { get; set; }

	[Export]
	public int MyExportedProperty { get; set; }

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
        /*
		var mesh = ResourceLoader.Load<Mesh>("res://assets/models/hex.obj");
		var mm = new MultiMesh();
		mm.TransformFormat = MultiMesh.TransformFormatEnum.Transform3D;
		mm.InstanceCount = 100;
		mm.Mesh = mesh;
		meshInstance = (MeshInstance3D)FindChild("MeshInstance3D");
		meshInstance.Visible = false;
		//mm.Mesh = (Mesh)meshInstance.Mesh.Duplicate();

		for (int i = 0; i < mm.InstanceCount; i++)
		{
			var transform = new Transform3D(Basis.Identity, new Vector3(GD.RandRange(-10, 10), 0, GD.RandRange(-10, 10)));
			mm.SetInstanceTransform(i, transform);
		}

		var mmi = new MultiMeshInstance3D();
		mmi.Multimesh = mm;
		AddChild(mmi);
		*/

        //var _grid = ResourceLoader.Load<HexGridView>("res://assets/prefabs/GridView.tscn");
        //AddChild(_grid);
        GridView.Window = new Rect2(-10, -10, 20, 20);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	public override void _Input(InputEvent @event)
	{
		if (@event is InputEventScreenDrag eventDrag)
		{

		}
	}
}
