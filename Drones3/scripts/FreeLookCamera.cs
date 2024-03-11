using Godot;
using System;

public partial class FreeLookCamera : Camera3D
{
    private float mouseSensitivity = 0.005f;
    private float speed = 4.0f;

    public override void _Ready()
    {
        //Input.MouseMode = Input.MouseModeEnum.Captured;
    }

    public override void _Process(double delta)
    {
        var velocity = Vector3.Zero;

        // Обработка ввода для перемещения камеры
        if (Input.IsActionPressed("move_forward"))
            velocity.Z -= 1;
        if (Input.IsActionPressed("move_backward"))
            velocity.Z += 1;
        if (Input.IsActionPressed("move_left"))
            velocity.X -= 1;
        if (Input.IsActionPressed("move_right"))
            velocity.X += 1;
        if (Input.IsActionPressed("move_up"))
            velocity.Y += 1;
        if (Input.IsActionPressed("move_down"))
            velocity.Y -= 1;

        // Нормализация вектора скорости
        velocity = velocity.Normalized() * speed;

        if (Input.IsKeyPressed(Key.Shift))
        {
            velocity *= 2;
        }

        // Перемещение камеры
        Translate(velocity * (float)delta);

        // Обработка ввода для вращения камеры
        //if (Input.IsActionPressed("action_view"))
        //{
        //    var mouseDelta = Input.GetLastMouseVelocity();
        //    RotateY(mouseDelta.X * mouseSensitivity);
        //    RotateX(mouseDelta.Y * mouseSensitivity);
        //}
    }

    public override void _Input(InputEvent @event)
    {
        if (@event is InputEventMouseMotion emm)
        {
            if (Input.IsActionPressed("action_view"))
            {
                // Вращение по оси Yaw (вертикальная вращение)
                var yaw = emm.Relative.X * mouseSensitivity;

                // Вращение по оси Pitch (наклон)
                var pitch = emm.Relative.Y * mouseSensitivity;

                if (Math.Abs(yaw) < Math.Abs(pitch))
                {
                    yaw = 0;
                }
                else
                {
                    pitch = 0;
                }

                // Ограничение угла Pitch, чтобы избежать переворота камеры
                pitch = Mathf.Clamp(pitch, -Mathf.Pi / 2, Mathf.Pi / 2);

                RotateY(yaw);
                RotateObjectLocal(new Vector3(1, 0, 0), -pitch);
            }
        }
    }
}