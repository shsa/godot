using Godot;
using System;

public partial class CameraMinecraftNavigator : Camera3D
{
    private Vector2 _initialPinchDistance;
    private bool _isPinching;

    private double _timer = 0;
    private float _total_pitch = 0.0f;
    private bool _touch_pressed = false;
    private double _touch_start_time = 0.0;
    private Vector2 _touch_start_position = Vector2.Zero;
    private Vector3 _start_position = Vector3.Zero;
    private double _click_delta = 0.5;

    public override void _Ready()
    {
        // Ensure the camera's drag margin is set to 0 to capture all input events
        //DragMargin = new Vector2(0, 0);
    }

    public override void _Process(double delta)
    {
        _timer += delta;

        var speed = 1.0f;

        var move = new Vector3(0, 0, 0);
        if (Input.IsActionPressed("move_forward"))
        {
            move.Z = -1;
        }
        if (Input.IsActionPressed("move_backward"))
        {
            move.Z = 1;
        }
        if (Input.IsActionPressed("move_left"))
        {
            move.X = -1;
        }
        if (Input.IsActionPressed("move_right"))
        {
            move.X = 1;
        }
        if (Input.IsActionPressed("move_up"))
        {
            move.Y = 1;
        }
        if (Input.IsActionPressed("move_down"))
        {
            move.Y = -1;
        }

        Translate(new Vector3(move.X * speed, 0, 0));
        var direction = new Vector3(Transform.Basis.Z.X, 0, Transform.Basis.Z.Z);
        direction = direction.Normalized() * move.Z * speed;
        Position += direction;

        direction = new Vector3(0, Transform.Basis.Y.Y, 0);
        direction = direction.Normalized() * move.Y * speed;
        Position += new Vector3(0, move.Y * speed, 0);

    }

    private Vector2 _ScreetToLocal(Vector2 screen_point)
    {
        var world_position = ProjectPosition(screen_point, Position.Y);
        var position = ToLocal(world_position);
        return new Vector2(position.X, position.Z);

    }

    public override void _Input(InputEvent @event)
    {
        if (@event is InputEventMouseMotion emm)
        {
            if (Input.IsActionPressed("action_view"))
            {
                var speed = 0.5f;
                var yaw = emm.Relative.X * speed;
                var pitch = emm.Relative.Y * speed;

                if (Math.Abs(yaw) < Math.Abs(pitch))
                {
                    yaw = 0;
                }
                else
                {
                    pitch = 0;
                }

                // Prevents looking up/down too far
                pitch = Math.Clamp(pitch, -90 - _total_pitch, 90 - _total_pitch);
                _total_pitch += pitch;
                RotateY(Mathf.DegToRad(yaw));
                RotateObjectLocal(new Vector3(1, 0, 0), Mathf.DegToRad(-pitch));
            }
        }

        if (@event is InputEventMouseButton emb)
        {
            if (emb.ButtonIndex == MouseButton.Left)
            {
                if (emb.IsPressed())
                {
                    _touch_pressed = true;
                    _touch_start_time = _timer;
                    _touch_start_position = emb.Position;
                    _start_position = Position;
                }
                else
                {
                    _touch_pressed = false;
                    if ((_timer - _touch_start_time) < _click_delta)
                    {
                        var move_delta = (emb.Position - _touch_start_position).Length();
                        var point = _ScreetToLocal(emb.Position);
                    }
                }
            }
        }

        if (@event is InputEventScreenDrag eventDrag)
        {
            //if (eventDrag.GetFingerCount() == 2) // Check for two fingers
            //{
            //    if (!_isPinching)
            //    {
            //        _isPinching = true;
            //        _initialPinchDistance = eventDrag.GetFingerPosition(0).DistanceTo(eventDrag.GetFingerPosition(1));
            //    }
            //    else
            //    {
            //        float currentPinchDistance = eventDrag.GetFingerPosition(0).DistanceTo(eventDrag.GetFingerPosition(1));
            //        float delta = _initialPinchDistance - currentPinchDistance;

            //        // Adjust the camera's zoom based on the pinch gesture
            //        Zoom -= new Vector2(delta * 0.01f, delta * 0.01f);
            //        Zoom = new Vector2(Mathf.Clamp(Zoom.x, 0.1f, 5.0f), Mathf.Clamp(Zoom.y, 0.1f, 5.0f)); // Limit zoom level

            //        _initialPinchDistance = currentPinchDistance;
            //    }
            //}
            //else
            //{
            //    _isPinching = false;
            //}
            //InputEventScreenDrag
        }
    }
}
