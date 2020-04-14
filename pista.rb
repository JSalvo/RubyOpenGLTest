require 'opengl'
require 'glu'
require 'glut'
require 'matrix'
include Gl,Glu,Glut, Math

$windowW = 800
$windowH = 600

$txc = 0
$tyc = 0

$startPoint = [0, 0]
$translation = [0, 0]

$zoom_factor = 0

$mzoom = 0.1


def to_rad(val)
	(Math::PI / 180.0) * val
end



# Produce una matrice di rotazione premoltiplicativa attorno all'asse x
def get_x_rotation_matrix(alpha)
	Matrix[
	[1.0, 0.0,              0.0,             0.0],
	[0.0, Math.cos(alpha), -Math.sin(alpha), 0.0],
	[0.0, Math.sin(alpha),  Math.cos(alpha), 0.0],
	[0.0, 0.0,              0.0,             1.0]]
end

def get_y_rotation_matrix(alpha)
	Matrix[
	[ Math.cos(alpha), 0.0, Math.sin(alpha), 0.0],
	[0.0,              1.0, 0.0,             0.0],
	[-Math.sin(alpha), 0.0, Math.cos(alpha), 0.0],
	[0.0,              0.0, 0.0,             1.0]]
end

def get_z_rotation_matrix(alpha)
	Matrix[
	[Math.cos(alpha), -Math.sin(alpha), 0.0, 0.0],
	[Math.sin(alpha),  Math.cos(alpha), 0.0, 0.0],
	[0.0,              0.0,             1.0, 0.0],
	[0.0,              0.0,             0.0, 1.0]]
end

def get_translation_matrix(tx, ty, tz)
	Matrix[
	[1.0, 0.0, 0.0, tx],
	[0.0, 1.0, 0.0, ty],
	[0.0, 0.0, 1.0, tz],
	[0.0, 0.0, 0.0, 1.0]]
end



class JLine
	def initialize(jp1, jp2)
		@jp1 = jp1
		@jp2 = jp2
	end

	def get_jp1
		@jp1
	end

	def get_jp2
		@jp2
	end

	def draw_jline
		glBegin(GL_LINES)
			@jp1.get_opengl_vertex
			@jp2.get_opengl_vertex
		glEnd()
	end
end

class JRectangle
	def initialize(jp, width, height)
		@width = width
		@height = height
		@jp1 = JPoint.new(jp.get_x, jp.get_y, jp.get_z)
		@jp2 = JPoint.new(@jp1.get_x, @jp1.get_y + height, @jp1.get_z)
		@jp3 = JPoint.new(@jp2.get_x + width, @jp2.get_y, @jp1.get_z)
		@jp4 = JPoint.new(@jp3.get_x, @jp1.get_y, @jp1.get_z)
	end

	def draw_jrectangle
		glBegin(GL_QUADS)
			@jp1.get_opengl_vertex
			@jp2.get_opengl_vertex
			@jp3.get_opengl_vertex
			@jp4.get_opengl_vertex
		glEnd()
	end
end

class JCircle
	def initialize(jp, radius)
		@jp = jp
		@radius = radius
	end

	def set_x(x)
		@jp.set_x(x)
	end

	def set_y(y)
		@jp.set_y(y)
	end

	def draw_jcircle
		glBegin(GL_QUADS)
			(0..20).each do |i|
				p1 = (@jp + JPoint.new(@radius * Math.cos(to_rad(i*18)), @radius * Math.sin(to_rad(i*18)), 0))
				p2 = (@jp + JPoint.new(@radius * Math.cos(to_rad((i+1)*18)), @radius * Math.sin(to_rad((i+1)*18)), 0))

				p1.get_opengl_vertex
				p2.get_opengl_vertex
				@jp.get_opengl_vertex
			end
		glEnd()
	end
end

class JVector(Array)
	def initialize(x, y, z)
		self.append(x).append(y).append(z)
	end

	def +(v2):
		JVector.new(self[0] + v2[0], self[1] + v2[1], self[2] + v2[2] )
	end

	def *(v2):
		return self[0]**2 + self[1]**2 + self[2]**2)
	end

	def per_scalar(s):
		JVector.new(s*self[0], s*self[1], s.self[2])
	end

	def normalize():
		d = Math.sqrt(self*self)
		result = self.per_scalar(1.0/d)
	end
end


class JCar
	def initialize(jposition)
		@jposition = jposition
		@time_start = 0
		@direction = [0, 0, 0]
	end
end

class JPoint
	def initialize(x, y, z=0.0)
		@x = x
		@y = y
		@z = z
	end

	def +(jp)
		result = JPoint.new(@x + jp.get_x, @y + jp.get_y, @z + jp.get_z)
	end

	def get_x
		@x
	end

	def get_y
		@y
	end

	def get_z
		@z
	end

	def set_x(x)
		@x = x
	end

	def set_y(y)
		@y = y
	end

	def set_z(z)
		@z = z
	end

	def get_opengl_vertex
		glVertex3f(@x, @y, @z)
	end
end

l1 = JLine.new(JPoint.new(-30, -25, 0), JPoint.new(30, -25, 0))
l2 = JLine.new(JPoint.new(-30, 25, 0), JPoint.new(30, 25, 0))

l3 = JLine.new(JPoint.new(-30, -25, 0), JPoint.new(-30, 25, 0))
l4 = JLine.new(JPoint.new(30, -25, 0), JPoint.new(30, 25, 0))


c1 = JCircle.new(JPoint.new(0, 15, 0), 5)

display = proc do
	glClear(GL_COLOR_BUFFER_BIT)
	glColor3f(1.0, 1.0, 1.0)
	l1.draw_jline()
	l2.draw_jline()
	l3.draw_jline()
	l4.draw_jline()
	c1.draw_jcircle()
	glFlush()
end

reshape = proc do
	$windowW = glutGet(GLUT_WINDOW_WIDTH)
	$windowH = glutGet(GLUT_WINDOW_HEIGHT)
	glViewport(0, 0, $windowW, $windowH)
	#init($windowW, $windowH)

	reset_camera($windowW, $windowH)
end


def viewer_scale(s)
	glScalef(1.0/s, 1.0/s, 1)
end

def viewer_translation(tx, ty)
	glTranslatef(-tx, -ty, 0)
end

def init(window_width, window_height)
	glMatrixMode(GL_MODELVIEW)
	glLoadIdentity()

	glMatrixMode(GL_PROJECTION)
	glLoadIdentity();
	# La stanza di visualizzazione, viene "scalata" con tutto il suo contenuto

	glClearColor(0.0, 0.0, 0.0, 0.0)

	# Definisco un parallelepipedo, che delimiti la mia area di visualizzazione
	# Si immagini il parallelepipedo come una stanza
	# glOrtho(left, right, bottom, top, near, far)
	# left indica la posizione della parete sinistra. Tutto ciò che è a sinistra
	# del piano di taglio sinistro, non viene visualizzato
	# right indica la posizione della parete destra. Tutto ciò che è a destra del
	# piano di taglio destro, non viene visualizzato
	# Considerazioni analoghe a quelle di cui sopra valgono per il piano di taglio bottom (pavimento)
	# top (tetto), near la "parete" frontale all'osservatore e far la "parete" opposta alla frontale
	# più distante rispetto all'osservatore. Si immagini, che il contenuto del parallelepipedo
	# o della stanza, venga proiettato ortogonalmente, sulla parete frontale
	glOrtho(-window_width/2, window_width/2, -window_height/2, +window_height/2, -1.0, 1.0)

	viewer_scale($mzoom)


	viewer_translation($txc, $tyc)


end

def reset_camera(window_width, window_height)
	glMatrixMode(GL_MODELVIEW)
	glLoadIdentity()

	glMatrixMode(GL_PROJECTION)
	glLoadIdentity();

	glOrtho(-window_width / 2, window_width / 2, -window_height / 2, +window_height / 2, -1.0, 1.0)

	viewer_scale($mzoom)
	viewer_translation($txc, $tyc)


	glutPostRedisplay()
end

require 'chipmunk'

space = CP::Space.new
space.gravity = vec2(0, 0)


# FORMA STATICA, SU CUI SCORRERA' LA BALL
a = vec2(-30, -25)
b = vec2(30, -25)
static_body_segment1 = CP::StaticBody.new
shape_segment1 = CP::Shape::Segment.new(static_body_segment1, a, b, 1.0)

a = vec2(-30, 25)
b = vec2(30, 25)
static_body_segment2 = CP::StaticBody.new
shape_segment2 = CP::Shape::Segment.new(static_body_segment2, a, b, 1.0)

a = vec2(-30, -25)
b = vec2(-30, 25)
static_body_segment3 = CP::StaticBody.new
shape_segment3 = CP::Shape::Segment.new(static_body_segment3, a, b, 1.0)

a = vec2(30, -25)
b = vec2(30, 25)
static_body_segment4 = CP::StaticBody.new
shape_segment4 = CP::Shape::Segment.new(static_body_segment4, a, b, 1.0)

# BALL
radius = 5
mass = 1
moment = CP::moment_for_circle(mass, 0, radius, vec2(0, 0))


body_ball = CP::Body.new(mass, moment)
body_ball.pos = vec2(0, 15)
shape_ball = CP::Shape::Circle.new body_ball, radius, vec2(0, 0)

# AGGIUNGO I CORPI ...
space.add_body(body_ball)

# ... E LE FORME ALLO SPAZIO ...
space.add_shape(shape_ball)
space.add_static_shape(shape_segment1)
space.add_static_shape(shape_segment2)
space.add_static_shape(shape_segment3)
space.add_static_shape(shape_segment4)

class CollisionHandler
  def begin(a, b, arbiter)
    p "Collisioni iniziate..."
    true
  end

  def pre_solve(a, b)
    true
  end

  def post_solve(arbiter)
    true
  end
end


space.add_collision_handler :foo, :foo, CollisionHandler.new


do_stuff = -> value {
	p ({
		:ball_position => [body_ball.pos.x, body_ball.pos.y],
		:ball_velocity => [body_ball.v.x, body_ball.v.y]
		})
		space.step(1.0 / 60.0)

		c1.set_x(body_ball.pos.x)
		c1.set_y(body_ball.pos.y)

		glutTimerFunc(17, do_stuff, 1)

		reset_camera($windowW, $windowH)
}


keyboard = -> key, x, y{
	puts case key
	when GLUT_KEY_UP
		#$tyc += 1
		f = vec2(0, 1)
		body_ball.f = f
		#reset_camera($windowW, $windowH)
	when GLUT_KEY_DOWN
		#$tyc -= 1
		f = vec2(0, -1)
		body_ball.f = f


	when GLUT_KEY_LEFT
		#$txc -= 1
		f = vec2(-1, 0)
		body_ball.f = f
		#reset_camera($windowW, $windowH)
	when GLUT_KEY_RIGHT
		#$txc += 1
		f = vec2(1, 0)
		body_ball.f = f
		#reset_camera($windowW, $windowH)
	end
}

keyboard_up = -> key, x, y{
	puts case key
	when GLUT_KEY_UP
		reset_camera($windowW, $windowH)
	when GLUT_KEY_DOWN
		#$tyc -= 1
		p "Orpo di Bacco!!!"
		if false
		p ({
		  :ball_position => [body_ball.pos.x, body_ball.pos.y],
		  :ball_velocity => [body_ball.v.x, body_ball.v.y]
		  })
		  space.step(1.0 / 60.0)

			c1.set_x(body_ball.pos.x)
			c1.set_y(body_ball.pos.y)
		end

		reset_camera($windowW, $windowH)
	when GLUT_KEY_LEFT

		reset_camera($windowW, $windowH)
	when GLUT_KEY_RIGHT

		reset_camera($windowW, $windowH)
	end
}

mouse = -> button, state, x, y {
	puts case button
	when GLUT_LEFT_BUTTON
		if state == GLUT_DOWN
			$startPoint = [x, y]
			p "Mouse sinistro giù"
		else
			p "Mouse sinistro su"

		end

	when GLUT_RIGHT_BUTTON
		if state == GLUT_DOWN
			$startPoint = [x, y]

			p "Mouse destro giù"

		else
			p "Mouse destro su"

		end

	when GLUT_MIDDLE_BUTTON
		if state == GLUT_DOWN
			p "Mouse centrale giù"
      $startPoint = [x, y]
		else
			p "Mouse centrale su"
		end
	when 3
		p "Routa su"
		$zoom_factor += 1

		if $zoom_factor < 0
			$mzoom = -$zoom_factor
		else
			$mzoom = 1.0 / ($zoom_factor**(0.5) + 1)
		end
		reset_camera($windowW, $windowH)

	when 4
		p "Routa giù"
$zoom_factor -= 1

		if $zoom_factor < 0
			$mzoom = -$zoom_factor
		else
			$mzoom = 1.0 / ($zoom_factor**(0.5) + 1)
		end
		reset_camera($windowW, $windowH)
	end
}


mouse_move = -> x, y{
	$txc += -(x - $startPoint[0]) * $mzoom
	$tyc += +(y - $startPoint[1]) * $mzoom

$startPoint = [x, y]
	reset_camera($windowW, $windowH)
}




mouse_move_passive = -> x, y{
	glutWarpPointer(x/10 * 10, y/10 * 10);
}




glutInit()
glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB)
glutInitWindowSize($windowW, $windowH)
glutInitWindowPosition(0, 0)
glutCreateWindow("Ciao bigolo")
init($windowW, $windowH);

glutSpecialFunc(keyboard)
glutSpecialUpFunc(keyboard_up)
glutMouseFunc(mouse)
glutMotionFunc(mouse_move)

glutTimerFunc(17, do_stuff, 1)


#glutPassiveMotionFunc(mouse_move_passive)
#glutSpecialUpFunc(keyboardglutMouseWheelFunc(mouse_wheel))

glutDisplayFunc(display)
glutReshapeFunc(reshape)

#glutKeyboardFunc(keyboard)

glutMainLoop()
