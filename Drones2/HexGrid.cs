using Godot;
using System;
using System.Drawing;

namespace Drones2
{
    public class HexGrid
    {
        private float _short;
        private float _long;
        // матрица базиса вспомогательной сетки
        private Transform2D _grid_basis = new Transform2D();
        // матрица базиса гексагональной сетки
        private Transform2D _hex_basis = new Transform2D();

        public float SideSize { get; private set; }

        public HexGrid(float side_size) 
        {
            SideSize = side_size;

            _short = (float)(side_size * Math.Sqrt(3) / 2); // половина короткой диагонали
            _long = side_size / 2; // четверть длинной диагонали

            // для горизонтальной сетки
            _grid_basis.X = new Vector2(_short, 0);
            _grid_basis.Y = new Vector2(0, _long);

            _hex_basis.X = _grid_basis.X * 2;
            _hex_basis.Y = _grid_basis.X + _grid_basis.Y * 3;
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
    }
}
