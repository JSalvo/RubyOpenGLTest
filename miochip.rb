require 'chipmunk'

space = CP::Space.new
space.gravity = vec2(0, -100)


# FORMA STATICA, SU CUI SCORRERA' LA BALL
a = vec2(-20, 5)
b = vec2(20, -5)
static_body_segment = CP::StaticBody.new
shape_segment = CP::Shape::Segment.new(static_body_segment, a, b, 1.0)


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
space.add_static_shape(shape_segment)

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

(0..30).each do |i|
p ({
  :ball_position => [body_ball.pos.x, body_ball.pos.y],
  :ball_velocity => [body_ball.v.x, body_ball.v.y]
  })
  space.step(1.0 / 60.0)
  sleep(1)
end
