require 'opengl'
require 'glu'
require 'glut'
require 'matrix'
include Gl,Glu,Glut

windowH = 800
windowW = 600

$txc = 0
$tyc = 0

$startPoint = [0, 0]
$translation = [0, 0]


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
	glFlush()
end

def viewer_scale(s)
	glScalef(1.0/s, 1.0/s, 1)
end

def viewer_translation(tx, ty)
	glTranslatef(-tx, -ty, 0)
end

def init
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
	glOrtho(-400, 400, -300, +300, -1.0, 1.0)

	viewer_scale(5)
	viewer_translation($txc, $tyc)
end

def reset_camera
	glMatrixMode(GL_MODELVIEW)
	glLoadIdentity()

	glMatrixMode(GL_PROJECTION)
	glLoadIdentity();

	glOrtho(-400, 400, -300, +300, -1.0, 1.0)

	viewer_translation($txc, $tyc)
	viewer_scale(5)

	glutPostRedisplay()
end

keyboard = -> key, x, y{
	puts case key
	when GLUT_KEY_UP
		$tyc += 1
		reset_camera()
	when GLUT_KEY_DOWN
		$tyc -= 1
		reset_camera()
	when GLUT_KEY_LEFT
		$txc -= 1
		reset_camera()
	when GLUT_KEY_RIGHT
		$txc += 1
		reset_camera()
	end
}

mouse = -> button, state, x, y {
	puts case button
	when GLUT_LEFT_BUTTON
		if state == GLUT_DOWN
			p "Mouse sinistro giù"
		else
			p "Mouse sinistro su"

		end

	when GLUT_RIGHT_BUTTON
		if state == GLUT_DOWN
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
	end
}


mouse_move = -> x, y{
	$txc = -(x - $startPoint[0])
	$tyc = +(y - $startPoint[1])

	reset_camera()
}



mouse_move_passive = -> x, y{
	glutWarpPointer(x/10 * 10, y/10 * 10);
}




glutInit()
glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB)
glutInitWindowSize(windowH, windowW)
glutInitWindowPosition(0, 0)
glutCreateWindow("Ciao bigolo")
init();
get_x_rotation_matrix(45)
glutSpecialFunc(keyboard)
glutMouseFunc(mouse)
glutMotionFunc(mouse_move)
#glutPassiveMotionFunc(mouse_move_passive)
#glutSpecialUpFunc(keyboard)
glutDisplayFunc(display)
#glutKeyboardFunc(keyboard)
glutMainLoop()
