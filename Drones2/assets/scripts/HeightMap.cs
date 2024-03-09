using Godot;

public class HeightMap
{
    private Image _image;

    public float Scale { get; set; } = 1.0f;

    public float HeightScale { get; set; } = 1.0f;

    public HeightMap()
    {
        _image = new Image();
        _image.Load("res://assets/map/80001d32-0002-f400-b63f-84710c7967bb_heightmap.png");
    }

    public float GetHeight(Vector2 position)
    {
        var w = _image.GetWidth();
        var h = _image.GetHeight();
        var x = (int)(position.X / Scale + w / 2);
        var y = (int)(position.Y / Scale + h / 2);

        if (x < 0)
        {
            return 0;
        }
        if (x >= w)
        {
            return 0;
        }
        if (y < 0)
        {
            return 0;
        }
        if (y >= h)
        {
            return 0;
        }

        var color = _image.GetPixel(x, y);
        return (color.R + color.G + color.B) / 3 * HeightScale;
    }
}
