using Godot;
using System;
using System.Collections.Generic;

// https://habr.com/ru/articles/557496/
public class HexGrid
{
    // матрица базиса вспомогательной сетки
    private Transform2D _grid_basis = new Transform2D();
    // матрица базиса гексагональной сетки
    private Transform2D _hex_basis = new Transform2D();

    private Dictionary<Vector2, HexGridTile> _tileChache = new Dictionary<Vector2, HexGridTile>();

    private float _tileWidth;
    private float _tileHeight;

    public Vector2[] hex_normals = new Vector2[6];
    public Vector2[] hex_plane_origin = new Vector2[6];

    public float Short;
    public float Long;

    public float SideSize { get; private set; }
    public int TileSize { get; private set; }

    public HexGrid(int tileSize)
    {
        TileSize = tileSize % 2 == 0 ? tileSize : tileSize + 1;

        Long = 0.25f; // четверть длинной диагонали
        SideSize = 2 * Long;
        Short = SideSize * Mathf.Sqrt(3f) / 2; // половина короткой диагонали

        _tileWidth = tileSize * Short * 2;
        _tileHeight = tileSize * Long * 3;

        // для горизонтальной сетки
        _grid_basis.X = new Vector2(Short, 0);
        _grid_basis.Y = new Vector2(0, Long);

        _hex_basis.X = _grid_basis.X * 2;
        _hex_basis.Y = _grid_basis.X + _grid_basis.Y * 3;
        TileSize = tileSize;

        hex_plane_origin[0] = new Vector2(-Short * 0.5f, -Long * 1.5f);
        hex_plane_origin[1] = new Vector2(Short * 0.5f, -Long * 1.5f);
        hex_plane_origin[2] = new Vector2(Short, 0);
        hex_plane_origin[3] = new Vector2(Short * 0.5f, Long * 1.5f).Normalized();
        hex_plane_origin[4] = new Vector2(-Short * 0.5f, Long * 1.5f).Normalized();
        hex_plane_origin[5] = new Vector2(-Short, 0).Normalized();

        hex_normals[0] = hex_plane_origin[0].Normalized();
        hex_normals[1] = hex_plane_origin[1].Normalized();
        hex_normals[2] = hex_plane_origin[2].Normalized();
        hex_normals[3] = hex_plane_origin[3].Normalized();
        hex_normals[4] = hex_plane_origin[4].Normalized();
        hex_normals[5] = hex_plane_origin[5].Normalized();
    }

    public Vector2 Cell2Pixel(Vector2 cell)
    {
        return cell.X * _grid_basis.X + cell.Y * _grid_basis.Y;
    }

    public Vector2 Pixel2Cell(Vector2 pixel, bool rounding = true)
    {
        var res = _grid_basis.AffineInverse().BasisXform(pixel);
        if (rounding)
        {
            res = res.Floor();
        }
        return res;
    }

    public Vector2 Hex2Pixel(Vector2 hex)
    {
        return hex.X * _hex_basis.X + hex.Y * _hex_basis.Y;
    }

    public Vector2 Pixel2Hex(Vector2 pixel)
    {
        return RoundHex(_hex_basis.AffineInverse().BasisXform(pixel));
    }

    public Vector2 RoundHex(Vector2 hex)
    {
        var rx = Mathf.Round(hex.X);
        var ry = Mathf.Round(hex.Y);
        var rz = Mathf.Round(-hex.X - hex.Y);

        var x_diff = Mathf.Abs(hex.X - rx);
        var y_diff = Mathf.Abs(hex.Y - ry);
        var z_diff = Mathf.Abs(-hex.X - hex.Y - rz);
        if (x_diff > y_diff && x_diff > z_diff)
        {
            rx = -ry - rz;
        }
        else if (y_diff > z_diff)
        {
            ry = -rx - rz;
        }
        return new Vector2(rx, ry);
    }


    public Vector2 GetCenterCell(Vector2 hex)
    {
        return new Vector2(hex.X * 2 + hex.Y, hex.Y * 3);
    }

    public Vector2[] GetHexVerticesFromPixel(Vector2 pixel)
    {
        return new[] {
            pixel - _grid_basis.X - _grid_basis.Y,
            pixel - 2 * _grid_basis.Y,
            pixel + _grid_basis.X - _grid_basis.Y,
            pixel + _grid_basis.X + _grid_basis.Y,
            pixel + 2 * _grid_basis.Y,
            pixel - _grid_basis.X + _grid_basis.Y,
        };
    }

    /// <summary>
    /// Returns the distance from the ray origin to the intersection point or null if there is no intersection.
    /// </summary>
    private bool IsRayToLineSegmentIntersection(Vector2 rayOrigin, Vector2 rayDirection, Vector2 point1, Vector2 point2)
    {
        /*
Пусть v - направление луча, v1, v2 - направления векторов из начала луча в концы отрезка. Пусть (a, b) - скалярное произведение векторов, a * b - векторное (a.x * b.y - a.y * b.x). Тогда справделиво следующее:

    Если v1 * v2 = 0, то проверяем v1 * v. Если оно нулевое, то проверяем скалярные произведения (v1, v) и (v2, v). Если среди них есть положительное - часть отрезка или весь он лежит на луче. Сам решай, что делать в этом случае :) Если положительного нет, но один нулевой - отрезок и луч имеют общую точку - вершину луча. Если оба отрицательные - отрезок и луч не пересекаются.
    Если же v1 * v было ненулевое, то проверяем (v1, v2). Если оно положительное - отрезок и луч не имеют общих точек, иначе пересекаются в вершине луча.
    Если среди v1 * v и v * v2 есть один нуль (оба быть не могут, т.к. в этом случае выполняется п. 1), то проверяем скалярное произведение этой нулевой пары векторов. Если оно больше нуля, то соответствующая вершина лежит на луче, иначе отрезок не пересекает луч.
    Остался случай, когда v1 * v и v * v2 ненулевые. Если оба эти значения и v1 * v2 имеют одинаковые знаки, то отрезок пересекается с лучом, иначе - нет.

Собственно, в случаях 1 и 2 находить точку пересечения не надо - это вершина луча в первом и конец отрезка во втором случае. В третьем же случае если получилось, что они они пересекаются, просто находишь пересечение двух прямых через систему уравнений. 
         */

        // Нам нужно просто проверить факт пересечения, точка не нужна
        var v1 = point1 - rayOrigin;
        var v2 = point2 - rayOrigin;
        var a = v1.Cross(rayDirection);
        var b = rayDirection.Cross(v2);
        return (a * b) > 0;
    }

    public bool IntersectHexWithRay(Vector2 pixel, Vector2 ray_origin, Vector2 ray_direction)
    {
        var pp = GetHexVerticesFromPixel(pixel);
        for (int i = 0; i < hex_normals.Length; i++)
        {
            if (hex_normals[i].Dot(ray_direction) < 0)
            {
                //DebugDrawLine(pixel, pixel + _hex_normals[i], Colors.Orange);
                var p0 = pp[i];
                var p1 = i == 5 ? pp[0] : pp[i + 1];
                //DebugDrawLine(p0, p1, Colors.Red);

                //if (i == 4 && pixel == new Vector2(0.4330127f, -0.75f))
                //{
                //}


                // луч может пересечься с этой стороной
                var check = IsRayToLineSegmentIntersection(ray_origin, ray_direction, p0, p1);
                if (check)
                {
                    DebugDrawLine((p0 - pixel) * new Vector2(0.9f, 0.9f) + pixel, (p1 - pixel) * new Vector2(0.9f, 0.9f) + pixel, Colors.Orange, 10);
                    return true;
                }
            }
        }
        return false;
    }

    Vector2? GetNextHex(Vector2 pixel, Vector2 ray_origin, Vector2 ray_direction) 
    {
        var nbs = GetNeighborsFromPixel(pixel);
        Vector2? near = null;
        var lengthSqr = 0f;
        foreach (var nb in nbs)
        {
            var dir = (nb - pixel);
            if (dir.Dot(ray_direction) > 0)
            {
                //DebugDrawHex(nb, Colors.Blue);
                if (IntersectHexWithRay(nb, ray_origin, ray_direction))
                {
                    //DebugDrawHex(nb, Colors.Blue);
                    if (near == null)
                    {
                        near = nb;
                    }
                    else
                    {
                        var lenSql = dir.LengthSquared();
                        if (lenSql < lengthSqr)
                        {
                            lengthSqr = lenSql;
                            near = nb;
                        }
                    }
                }
            }
        }

        return near;
    }

    public Vector2[] SelectHexFromLine(Vector2 start, Vector2 end)
    {
        DebugDraw.Add(new DebugDraw.Line(new Vector3(start.X, 0, start.Y), new Vector3(end.X, 0, end.Y), Colors.Red));

        var result = new List<Vector2>();

        var hex = Pixel2Hex(start);
        var pixel = Hex2Pixel(RoundHex(hex));
        DebugDrawHex(pixel, Colors.Green);

        var ray_origin = start;
        var ray_direction = end - start;
        var hex_pixel = GetNextHex(pixel, ray_origin, ray_direction);
        while (hex_pixel != null && (end - (Vector2)hex_pixel).Dot(ray_direction) > 0)
        {
            hex_pixel = GetNextHex((Vector2)hex_pixel, ray_origin, ray_direction);
            result.Add((Vector2)hex_pixel);

            if (hex_pixel != null)
            {
                DebugDrawHex(hex_pixel.Value, Colors.Red);
            }
        }

        return result.ToArray();
    }

    public IEnumerable<HexGridTile> GetTiles(Rect2 rect)
    {
        var list = new List<HexGridTile>();

        var left = (int)Math.Floor(rect.Position.X / _tileWidth);
        var top = (int)Math.Floor(rect.Position.Y / _tileHeight);
        var right = (int)Math.Ceiling((rect.Position.X + rect.Size.X) / _tileWidth);
        var bottom = (int)Math.Ceiling((rect.Position.Y + rect.Size.Y) / _tileHeight);

        for (int j = top; j <= bottom; j++)
        {
            for (int i = left; i <= right; i++)
            {
                var pos = new Vector2(i * _tileWidth, j * _tileHeight);
                if (!_tileChache.TryGetValue(pos, out var tile))
                {
                    tile = new HexGridTile(this, pos);
                    _tileChache.Add(pos, tile);
                }
                list.Add(tile);
            }
        }
        return list;
    }

    public void FreeTile(HexGridTile tile)
    {
        if (_tileChache.ContainsKey(tile.Offset))
        {
            _tileChache.Remove(tile.Offset);
        }
    }

    public Vector2[] GetNeighborsFromPixel(Vector2 pixel)
    {
        return new[]
        {
            new Vector2(pixel.X - Short, pixel.Y - 3 * Long),
            new Vector2(pixel.X + Short, pixel.Y - 3 * Long),
            new Vector2(pixel.X + 2 * Short, pixel.Y),
            new Vector2(pixel.X + Short, pixel.Y + 3 * Long),
            new Vector2(pixel.X - Short, pixel.Y + 3 * Long),
            new Vector2(pixel.X - 2 * Short, pixel.Y),
        };
    }

    public Vector2I[] GetNeighborsFromHex(Vector2I hex)
    {
        return new[]
        {
            new Vector2I(hex.X - 1, hex.Y),
            new Vector2I(hex.X + 1, hex.Y - 1),
            new Vector2I(hex.X, hex.Y - 1),
            new Vector2I(hex.X + 1, hex.Y),
            new Vector2I(hex.X, hex.Y + 1),
            new Vector2I(hex.X - 1, hex.Y + 1),
        };
    }

    private class HexDraw : DebugDraw.BaseDraw
    {
        public Vector3[] points;
        public Color color;

        public override void _Render(ImmediateMesh mesh)
        {
            mesh.SurfaceBegin(Mesh.PrimitiveType.LineStrip);
            
            foreach (var v in points)
            {
                mesh.SurfaceSetColor(color);
                mesh.SurfaceAddVertex(v * Transform);
            }

            mesh.SurfaceSetColor(color);
            mesh.SurfaceAddVertex(points[0] * Transform);

            mesh.SurfaceEnd();
        }
    }

    public void DebugDrawLine(Vector2 point1, Vector2 point2, Color color, int priority = 0)
    {
        var line = new DebugDraw.Line(new Vector3(point1.X, 0, point1.Y), new Vector3(point2.X, 0, point2.Y), color);
        line.Priority = priority;
        DebugDraw.Add(line);
    }

    public void DebugDrawHex(Vector2 pixel, Color color, float y = 0)
    {
        var scale = new Vector2(0.95f, 0.95f);
        var draw = new HexDraw();
        draw.color = color;
        draw.points = new Vector3[6];

        var vv = GetHexVerticesFromPixel(pixel);
        for (int i = 0; i < vv.Length; i++)
        {
            var p = (vv[i] - pixel) * scale + pixel;
            draw.points[i] = new Vector3(p.X, y, p.Y);
        }
        DebugDraw.Add(draw);
    }
}
