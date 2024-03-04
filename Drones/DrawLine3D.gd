extends Node2D

#https://github.com/klaykree/Godot-3D-Lines/tree/master

class Line:
	var Start
	var End
	var LineColor
	var time
	
	func _init(Start, End, LineColor, time):
		self.Start = Start
		self.End = End
		self.LineColor = LineColor
		self.time = time

class Text:
	var Position: Vector3
	var Text: String
	var time: float
	
	func _init(pos: Vector3, text: String, time = 0.0):
		self.Position = pos
		self.Text = text
		self.time = time

var Lines = []
var RemovedLine = false

var Texts = []

var font: Font
var font_size: float

func _ready():
	font = ThemeDB.fallback_font
	font_size = ThemeDB.fallback_font_size
	
func _process(delta):
	for i in range(len(Lines)):
		Lines[i].time -= delta
	
	if(len(Lines) > 0 || RemovedLine):
		queue_redraw() #Calls _draw
		RemovedLine = false

func _draw():
	var Cam = get_viewport().get_camera_3d()
	for i in range(len(Lines)):
		var ScreenPointStart = Cam.unproject_position(Lines[i].Start)
		var ScreenPointEnd = Cam.unproject_position(Lines[i].End)
		
		#Dont draw line if either start or end is considered behind the camera
		#this causes the line to not be drawn sometimes but avoids a bug where the
		#line is drawn incorrectly
		if(Cam.is_position_behind(Lines[i].Start) ||
			Cam.is_position_behind(Lines[i].End)):
			continue
		
		draw_line(ScreenPointStart, ScreenPointEnd, Lines[i].LineColor)
	
	for i in range(len(Texts)):
		var screen_pos = Cam.unproject_position(Texts[i].Position)
		draw_string(font, screen_pos, Texts[i].Text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	
	#Remove lines that have timed out
	var i = Lines.size() - 1
	while (i >= 0):
		if(Lines[i].time < 0.0):
			Lines.remove_at(i)
			RemovedLine = true
		i -= 1

	#Remove texts that have timed out
	i = Texts.size() - 1
	while (i >= 0):
		if(Texts[i].time < 0.0):
			Texts.remove_at(i)
		i -= 1

func DrawText(pos: Vector3, text: String, time = 0.0):
	Texts.append(Text.new(pos, text, time))

func DrawLine(Start, End, LineColor, time = 0.0):
	Lines.append(Line.new(Start, End, LineColor, time))

func DrawRay(Start, Ray, LineColor, time = 0.0):
	Lines.append(Line.new(Start, Start + Ray, LineColor, time))

func DrawCube(Center, HalfExtents, LineColor, time = 0.0):
	#Start at the 'top left'
	var LinePointStart = Center
	LinePointStart.x -= HalfExtents
	LinePointStart.y += HalfExtents
	LinePointStart.z -= HalfExtents
	
	#Draw top square
	var LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, -HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(-HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time);
	
	#Draw bottom square
	LinePointStart = LinePointEnd + Vector3(0, -HalfExtents * 2.0, 0)
	LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, -HalfExtents * 2.0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(-HalfExtents * 2.0, 0, 0)
	DrawLine(LinePointStart, LinePointEnd, LineColor, time);
	
	#Draw vertical lines
	LinePointStart = LinePointEnd
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time)
	LinePointStart += Vector3(0, 0, HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time)
	LinePointStart += Vector3(HalfExtents * 2.0, 0, 0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time)
	LinePointStart += Vector3(0, 0, -HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, time)
