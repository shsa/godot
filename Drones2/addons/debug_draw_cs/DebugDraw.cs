using Godot;
using System.Collections.Generic;
using System.Linq;

public partial class DebugDraw : MeshInstance3D
{
    public class BaseDraw
    {
        private Transform3D? _transform = null;
        public Transform3D Transform
        {
            get { return _transform ?? DefaultTransform; }
            set { _transform = value; }
        }

        public int Priority = 0;

        public virtual void _Render(ImmediateMesh mesh)
        {
        }
    }

    public class Line: BaseDraw
    {
        public Vector3 point1;
        public Vector3 point2;
        public Color color;

        public Line(Vector3 point1, Vector3 point2, Color color)
        {
            this.point1 = point1;
            this.point2 = point2;
            this.color = color;
        }

        public override void _Render(ImmediateMesh mesh)
        {
            _mesh.SurfaceBegin(Mesh.PrimitiveType.Lines);
            _mesh.SurfaceSetColor(color);

            _mesh.SurfaceAddVertex(Transform * point1);
            _mesh.SurfaceAddVertex(Transform * point2);

            _mesh.SurfaceEnd();
        }
    }

    private static ImmediateMesh _mesh = null;
    private StandardMaterial3D _material = null;
    private static List<BaseDraw> _list = new List<BaseDraw>();

    public static Transform3D DefaultTransform = new Transform3D(Basis.Identity, Vector3.Zero);

    public override void _Ready()
    {
        _mesh = new ImmediateMesh();

        _material = new StandardMaterial3D();
        _material.NoDepthTest = true;
        _material.ShadingMode = BaseMaterial3D.ShadingModeEnum.Unshaded;
        _material.VertexColorUseAsAlbedo = true;
        _material.Transparency = BaseMaterial3D.TransparencyEnum.Alpha;
        MaterialOverlay = _material;

        Mesh = _mesh;
    }

    public static void DrawLine(Vector3 begin_pos, Vector3 end_pos, Color color)
    {
        if (_mesh == null)
        {
            return;
        }
        _mesh.SurfaceBegin(Mesh.PrimitiveType.Lines);
        _mesh.SurfaceSetColor(color);

        _mesh.SurfaceAddVertex(begin_pos);
        _mesh.SurfaceAddVertex(end_pos);

        _mesh.SurfaceEnd();
    }

    public static void DrawLine(Vector3 begin_pos, Vector3 end_pos)
    {
        DrawLine(begin_pos, end_pos, Colors.Red);
    }

    public static void Add(BaseDraw draw)
    {
        _list.Add(draw);
    }

    public static void Clear()
    {
        _list.Clear();
    }


    public override void _Process(double delta)
    {
        _mesh.ClearSurfaces();

        foreach (var draw in _list.OrderByDescending(i => i.Priority))
        {
            draw._Render(_mesh);
        }
    }
}
