using Godot;
using System.Collections;
using System.Collections.Generic;

public class HexGridTile : IEnumerable<Vector2>
{
    public HexGrid Grid { get; private set; }
    public Vector2 Offset { get; private set; }

    public double TimeUpdate { get; set; } = 0;

    public HexGridTile(HexGrid grid, Vector2 offset)
    {
        Grid = grid;
        Offset = offset;
    }

    public IEnumerator<Vector2> GetEnumerator()
    {
        var x = Offset.X - (Grid.TileSize - 1) * Grid.Short;
        var y = Offset.Y - (Grid.TileSize - 1) * Grid.Long * 3;
        var list = new List<Vector2>();
        for (int j = 0; j < Grid.TileSize; j++)
        {
            for (int i = 0; i < Grid.TileSize; i++)
            {
                list.Add(new Vector2(x + i * 2 * Grid.Short + (j % 2 == 0 ? 0 : Grid.Short), y + j * 3 * Grid.Long));
            }
        }
        return list.GetEnumerator();
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }
}
