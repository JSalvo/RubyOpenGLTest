require 'opengl'
require 'glu'
require 'glut'
include Gl,Glu,Glut

windowH = 800
windowW = 600

$txc = 0
$tyc = 0



display = proc do
	glClear(GL_COLOR_BUFFER_BIT)
	glColor3f(1.0, 1.0, 1.0)
	
	glMatrixMode(GL_MODELVIEW)
	glLoadIdentity()
	
	glRotate(45, 0, 0, 1)


	glBegin(GL_POLYGON)
		glVertex3f(-0.25, -0.25, 0.0)
		glVertex3f(+0.25, -0.25, 0.0)
		glVertex3f(+0.25, +0.25, 0.0)
		glVertex3f(-0.25, +0.25, 0.0)
	glEnd()

	glFlush()
end

def viewer_scale(s)
	glScalef(1.0/s, 1.0/s, 1)
end

def viewer_translation(tx, ty)
	glTranslatef(-tx, -ty, 0)
end


def init
	glClearColor(0.0, 0.0, 0.0, 0.0)
	glMatrixMode(GL_PROJECTION)
	glLoadIdentity();
	# La stanza di visualizzazione, viene "scalata" con tutto il suo contenuto
		
	
	viewer_scale(5)
	viewer_translation($txc, $tyc)
	
	

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
	glOrtho(-0.4, 0.4, -0.3, +0.3, -1.0, 1.0)
end

def reset_camera
	glMatrixMode(GL_PROJECTION)
	glLoadIdentity();
		
	viewer_scale(5)
	viewer_translation($txc, $tyc)
	glOrtho(-0.4, 0.4, -0.3, +0.3, -1.0, 1.0)
	glutPostRedisplay()
end

keyboard = -> key, x, y {
	puts case key
	when GLUT_KEY_UP
		$tyc += 0.1
		reset_camera()
	when GLUT_KEY_DOWN
		$tyc -= 0.1
		reset_camera()
	when GLUT_KEY_LEFT
		$txc -= 0.1
		reset_camera()
	when GLUT_KEY_RIGHT
		$txc += 0.1
		reset_camera()
	end
}

mouzettung = -> button, state, x, y {
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
		else
			p "Mouse centrale su"
		end
	end

}

glutInit()
glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB)
glutInitWindowSize(windowH, windowW)
glutInitWindowPosition(0, 0)
glutCreateWindow("Ciao bigolo")
init();
glutSpecialFunc(keyboard)
glutMouseFunc(mouzettung)
#glutSpecialUpFunc(keyboard)
glutDisplayFunc(display)
#glutKeyboardFunc(keyboard)
glutMainLoop()






