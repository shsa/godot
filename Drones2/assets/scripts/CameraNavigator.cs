using Godot;
using System;

public partial class CameraNavigator : Camera3D
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

        var direction = Transform.Basis.Z;
        direction = direction.Normalized();
        if (Input.IsActionJustReleased("zoom_out"))
        {
            Transform = new Transform3D(Transform.Basis, Transform.Origin - direction * 0.5f);
        }
        if (Input.IsActionJustReleased("zoom_in"))
        {
            Transform = new Transform3D(Transform.Basis, Transform.Origin + direction * 0.5f);
        }
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
            if (_touch_pressed)
            {
                var delta = _ScreetToLocal(emm.Position) - _ScreetToLocal(_touch_start_position);
                if (emm.AltPressed)
                {
                    var yaw = emm.Relative.X;
                    var pitch = emm.Relative.Y;

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
                else
                {
                    var speed = 0.1f;
                    //Position = _start_position - new Vector3(delta.X, 0, delta.Y);
                    Translate(new Vector3(-emm.Relative.X * speed, 0, 0));

                    var direction = Transform.Basis.Z;
                    direction = direction.Normalized() * emm.Relative.Y * speed;
                    Position -= new Vector3(direction.X, 0, direction.Z);
                    //Translate(new Vector3(delta.X, delta.Y, 0));
                }
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
