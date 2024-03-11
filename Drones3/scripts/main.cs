using Drones3.scripts.map;
using Godot;
using Godot.Collections;
using System;

public partial class main : Node3D
{
	Dictionary<Color, Mesh> cubes = new Dictionary<Color, Mesh>();
    HeightMap heightMap = new HeightMap();
    
    // Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
        int size = 100;
        int half = size / 2;
        var color = new Color("#B39F7A");
        for (int i = -half; i < half; i++)
        {
            for (int j = -half; j < half; j++)
            {
                var h = heightMap.GetHeight(new Vector2I(i, j));
                var cube = CreateCube(color, new Vector3(i, h, j));
            }
        }
	}

    Mesh CreateCubeMesh(Color color)
    {
        var min_y = -1f;
        var max_y = 0f;

        // Определение вершин куба
        Vector3[] vertices = new Vector3[]
        {
            new Vector3(-0.5f, min_y, -0.5f),
            new Vector3(-0.5f, min_y, 0.5f),
            new Vector3(-0.5f, max_y, 0.5f),
            new Vector3(-0.5f, max_y, -0.5f),
            new Vector3(0.5f, min_y, -0.5f),
            new Vector3(0.5f, min_y, 0.5f),
            new Vector3(0.5f, max_y, 0.5f),
            new Vector3(0.5f, max_y, -0.5f)
        };

        // Определение граней куба
        int[][] faces = new int[][]
        {
            new int[] { 3, 2, 1, 0 },
            new int[] { 4, 5, 6, 7 },
            new int[] { 0, 1, 5, 4 },
            new int[] { 1, 2, 6, 5 },
            new int[] { 2, 3, 7, 6 },
            new int[] { 4, 7, 3, 0 }
        };

        // Определение цветов для каждой грани
        Color[] colors = new Color[]
        {
            color,
            color,
            color,
            color,
            color,
            color
        };

        //Color[] colors = new Color[]
        //{
        //    Colors.Red,
        //    Colors.Blue,
        //    Colors.Green,
        //    Colors.Orange,
        //    Colors.Yellow,
        //    Colors.Gray
        //};

        Vector3[] normals = new Vector3[]
        {
            new Vector3(-1, 0, 0),
            new Vector3(1, 0, 0),
            new Vector3(0, -1, 0),
            new Vector3(0, 0, 1),
            new Vector3(0, 1, 0),
            new Vector3(0, 0, -1),
        };

        // Создание нового ArrayMesh и SurfaceTool
        var mesh = new ArrayMesh();
        var surfaceTool = new SurfaceTool();
        surfaceTool.Begin(Mesh.PrimitiveType.Triangles);

        // Цикл по каждой грани
        for (int i = 0; i < faces.Length; i++)
        {
            // Установка цвета для вершин этой грани
            surfaceTool.SetColor(colors[i]);
            // Добавление вершин для этой грани
            for (int j = 0; j < 4; j++)
            {
                surfaceTool.SetNormal(normals[i]);
                surfaceTool.AddVertex(vertices[faces[i][j]]);
            }
            // Добавление двух треугольников для этой грани
            surfaceTool.AddIndex(i * 4);
            surfaceTool.AddIndex(i * 4 + 1);
            surfaceTool.AddIndex(i * 4 + 2);
            surfaceTool.AddIndex(i * 4);
            surfaceTool.AddIndex(i * 4 + 2);
            surfaceTool.AddIndex(i * 4 + 3);
        }

        // Генерация нормалей и тангентов
        //surfaceTool.GenerateNormals();
        //surfaceTool.GenerateTangents();

        // Применение изменений к мешу
        surfaceTool.Commit(mesh);

        var mat = ResourceLoader.Load<Material>("res://assets/materials/vertex_color_material.tres");
        mesh.SurfaceSetMaterial(0, mat);

        return mesh;
    }

	Node3D CreateCube(Color color, Vector3 position)
	{
        if (!cubes.TryGetValue(color, out var mesh))
        {
            mesh = CreateCubeMesh(color);
            cubes.Add(color, mesh);
        }

        var obj = new MeshInstance3D();
        obj.Mesh = mesh;
        obj.Position = position;
        var scale = 0.97f;
        obj.Scale = new Vector3(scale, position.Y, scale);

        AddChild(obj);
        return obj;
    }

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
