# See: https://github.com/beoran/chipmunk/tree/master/spec
# + http://chipmunk-physics.net/release/ChipmunkLatest-Docs/
require 'chipmunk' # gem install chipmunk

s = CP::Space.new
s.gravity = vec2(0,0)

b1 = CP::Body.new(5, 7)
b1.pos = vec2(400,600)
b1.v = vec2(30,1)
s1 = CP::Shape::Circle.new b1, 40
s1.collision_type = :foo

b2 = CP::Body.new(5, 7)
b2.pos = vec2(800,570)
b2.v = vec2(-30,1)
s2 = CP::Shape::Circle.new b2, 40
s2.collision_type = :foo

s.add_body(b1)
s.add_body(b2)
s.add_shape(s1)
s.add_shape(s2)

class CollisionHandler
  def begin(a, b, arbiter)
    p "Collision started..."
    true
  end

  def pre_solve(a, b)
    true
  end

  def post_solve(arbiter)
    true
  end
end

s.add_collision_handler :foo, :foo, CollisionHandler.new

while true
  p ({
    :b1_pos => b1.pos,
    :b1_v => b1.v,
    :b2_pos => b2.pos,
    :b2_v => b2.v,
  })
  s.step(1.0 / 10.0)
  sleep 0.1
end
