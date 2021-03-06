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

$mzoom = 1


def to_rad(val)
	(Math::PI / 180.0) * val
end


def draw_cilinder(radius, height, position=nil, direction=nil, detail=50)

	glMatrixMode(GL_MODELVIEW)
	glPushMatrix()
	glScalef(radius, radius, height)

	delta = 360.0 / detail
	glBegin(GL_TRIANGLES)
		(0..detail).each do |i|

			# Cerchio di base del cilindro
			glVertex3f(Math.cos(to_rad(delta * i)), Math.sin(to_rad(delta * i)), 0)
			glVertex3f(Math.cos(to_rad(delta * (i+1))), Math.sin(to_rad(delta * (i+1))), 0)
			glVertex3f(0, 0, 0)

			# Cerchio alto del cilindro
			glVertex3f(Math.cos(to_rad(delta * i)), Math.sin(to_rad(delta * i)), 1)
			glVertex3f(Math.cos(to_rad(delta * (i+1))), Math.sin(to_rad(delta * (i+1))), 1)
			glVertex3f(0, 0, 1)
		end
	glEnd()



	glPopMatrix()

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


class JPoint
	def initialize(x, y, z=0.0)
		@x = x
		@y = y
		@z = z
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

l1 = JLine.new(JPoint.new(0, 0, 0), JPoint.new(100, 100, 0))

display = proc do
	glClear(GL_COLOR_BUFFER_BIT)
	glColor3f(1.0, 1.0, 1.0)
	l1.draw_jline()
	draw_cilinder(20, 100)
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

keyboard = -> key, x, y{
	puts case key
	when GLUT_KEY_UP
		$tyc += 1
		reset_camera($windowW, $windowH)
	when GLUT_KEY_DOWN
		$tyc -= 1
		reset_camera($windowW, $windowH)
	when GLUT_KEY_LEFT
		$txc -= 1
		reset_camera($windowW, $windowH)
	when GLUT_KEY_RIGHT
		$txc += 1
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
glutMouseFunc(mouse)
glutMotionFunc(mouse_move)

#glutPassiveMotionFunc(mouse_move_passive)
#glutSpecialUpFunc(keyboardglutMouseWheelFunc(mouse_wheel))

glutDisplayFunc(display)
glutReshapeFunc(reshape)

#glutKeyboardFunc(keyboard)

glutMainLoop()
