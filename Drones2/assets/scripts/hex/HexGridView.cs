using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

public partial class HexGridView : Node3D
{
    private HexGrid _grid;
    private HeightMap _heightMap;

    private Dictionary<HexGridTile, MultiMeshInstance3D> _tileCache = new Dictionary<HexGridTile, MultiMeshInstance3D>();
    private Mesh _mesh;
    private float _meshScaleH = 1.0f;

    private MeshInstance3D _selected = null;
    
    [Export]
    public Camera3D Camera { get; set; }

    [Export]
    public Node3D Marker { get; set; }

    public HexGridView()
    {
    }

    public Rect2 Window { get; set; }

    float markerScale = 1.0f;
    public override void _Ready()
    {
        _grid = new HexGrid(100);
        _heightMap = new HeightMap();

        _mesh = ResourceLoader.Load<Mesh>("res://assets/models/hex.obj");
        var bounds = _mesh.GetAabb();
        _meshScaleH = 1.0f / Mathf.Max(bounds.Size.X, bounds.Size.Z);

        var mi = (MeshInstance3D)Marker;
        var m = mi.Mesh;
        bounds = m.GetAabb();
        markerScale = 1 / bounds.Size.X;

        var mat = ResourceLoader.Load<Material>("res://assets/materials/hex_material.tres");
        _mesh.SurfaceSetMaterial(0, mat);

        _selected = new MeshInstance3D();
        _selected.Mesh = _mesh;
        _selected.Scale = new Vector3(1.1f, 1.1f, 1.1f);
        _selected.Position = new Vector3(0, 20, 0);
        _selected.MaterialOverride = ResourceLoader.Load<Material>("res://assets/materials/hex_selected_material.tres");
        AddChild(_selected);
        //_selected.Visible = false;
    }

    float GetHeight(Vector2 pixel)
    {
        var vv = _grid.GetHexVerticesFromPixel(pixel);
        var k = _heightMap.GetHeight(pixel);
        foreach (var v in vv)
        {
            k += _heightMap.GetHeight(v);
        }
        k = (int)Mathf.RoundToInt(k / 7 * 40);
        return k;
    }


    double _time = 0;
    public override void _Process(double delta)
    {
        _time += delta;

        var camera_pos = Camera.GlobalTransform.Origin;
        camera_pos = ToLocal(camera_pos);
        var center_x = camera_pos.X;
        var center_z = camera_pos.Z;
        var window_width = 200;
        var window_height = 200;
        Window = new Rect2(center_x - window_width / 2, center_z - window_height / 2, window_width, window_height);
        //Marker.Scale = new Vector3(window_width, 3, window_height);
        //Marker.Position = new Vector3(camera_pos.X, 2, camera_pos.Z);

        var scale = new Vector2(1 / Scale.X, 1 / Scale.Z);
        var _wnd = new Rect2(Window.Position * scale, Window.Size * scale);
        foreach (var _tile in _grid.GetTiles(_wnd))
        {
            if (!_tileCache.TryGetValue(_tile, out var _tileView))
            {
                var mm = new MultiMesh();
                mm.TransformFormat = MultiMesh.TransformFormatEnum.Transform3D;
                mm.InstanceCount = _grid.TileSize * _grid.TileSize;
                mm.Mesh = _mesh;

                var i = 0;
                foreach (var pos in _tile)
                {
                    var k = GetHeight(pos);

                    var transform = new Transform3D(Transform.Basis, new Vector3(pos.X, k, pos.Y) * Scale);
                    transform.Basis.X = new Vector3(transform.Basis.X.X * _meshScaleH, 0, 0);
                    transform.Basis.Z = new Vector3(0, 0, transform.Basis.Z.Z * _meshScaleH);
                    transform.Basis.Y = new Vector3(0, transform.Basis.Y.Y, 0);
                    mm.SetInstanceTransform(i, transform);
                    i++;
                }

                _tileView = new MultiMeshInstance3D();
                _tileView.Multimesh = mm;
                _tileCache.Add(_tile, _tileView);
                AddChild(_tileView);
            }
            _tile.TimeUpdate = _time;
        }

        foreach (var _tile in _tileCache.Keys.ToArray())
        {
            if ((_time - _tile.TimeUpdate) > 10)
            {
                var obj = _tileCache[_tile];
                obj.QueueFree();
                _tileCache.Remove(_tile);
                _grid.FreeTile(_tile);
            }
        }

        if (Input.IsActionJustPressed("action_button"))
        {
            // Определяем выделенный hex
            var _point1 = FindCameraRayIntersection();
            if (_point1 != null)
            {
                var point1 = (Vector2)_point1;
                DebugDraw.Clear();
                DebugDraw.DefaultTransform = Transform;
                //DebugDraw.Add(new DebugDraw.Line(new Vector3(center_x, 0, center_z), new Vector3(point1.X, 0, point1.Y), Colors.Red));

                var grid_point1 = new Vector2(point1.X / Scale.X, point1.Y / Scale.Z);
                var point0 = new Vector2(center_x, center_z);
                var grid_point0 = new Vector2(point0.X / Scale.X, point0.Y / Scale.Z);

                var list = _grid.SelectHexFromLine(grid_point0, grid_point1);

                var mousePosition = GetViewport().GetMousePosition();
                var rayOrigin = Camera.ProjectRayOrigin(mousePosition);
                var rayDirection = Camera.ProjectRayNormal(mousePosition);


                foreach (var item in list )
                {
                    if (IntersectCylinder(item, rayOrigin, rayDirection))
                    {
                        _grid.DebugDrawHex(item, Colors.Azure, 1);
                        var p = new Vector3(item.X, 0, item.Y);
                        p.Y = GetHeight(item) * 2;

                          _selected.Position = p;
                        _selected.Visible = true;
                        break;
                    }
                }
            }
        }

    }

    bool IntersectCylinder(Vector2 pixel, Vector3 rayOrigin, Vector3 rayDirection)
    {
        var k = GetHeight(pixel);
        var kv = new Vector3(0, k, 0);

        // Получаем нормаль плоскости из направления оси Z
        var normal = Transform.Basis.Y;

        // Получаем точку на плоскости из origin Transform
        var origin = kv + Transform.Origin;

        // Создаем плоскость
        var plane = new Plane(normal, origin.Dot(normal));
        var point = plane.IntersectsRay(rayOrigin, rayDirection);
        if (point == null)
        {
            return false;
        }

        var pixel3 = new Vector3(pixel.X, 0, pixel.Y) * Transform + kv;
        var lenSqr = (point.Value - pixel3).LengthSquared();
        return lenSqr <= (new Vector3(1, 0, 0) * Transform).LengthSquared();
    }

    public Vector2? FindCameraRayIntersection()
    {
        Vector2 mousePosition = GetViewport().GetMousePosition();
        Vector3 rayOrigin = Camera.ProjectRayOrigin(mousePosition);
        Vector3 rayDirection = Camera.ProjectRayNormal(mousePosition);

        // Получаем нормаль плоскости из направления оси Z
        var normal = Transform.Basis.Y;

        // Получаем точку на плоскости из origin Transform
        var origin = Transform.Origin;

        // Создаем плоскость
        var plane = new Plane(normal, origin.Dot(normal));
        var point = plane.IntersectsRay(rayOrigin, rayDirection);
        if (point == null)
        {
            return null;
        }
        return new Vector2(point.Value.X, point.Value.Z);
    }

    private Vector2 _mouse_position;
    public override void _Input(InputEvent @event)
    {
        if (@event is InputEventMouse iem)
        {
            _mouse_position = iem.Position;
        }
    }
}
