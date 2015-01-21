addTextNode = (text)->
  newtext = document.createTextNode text
  p1 = document.getElementById "p1"
  p1.appendChild newtext


setText = (element, text)->
	if "textContent" of Element::
	    element.textContent = text
	else
	    element.innerText = text


Element::setText = (text)->
  setText @, text

step = document.createElement "button"
step.setText "Step"
document.body.appendChild step

go = document.createElement "button"
go.setText "Go"
document.body.appendChild go
going = yes

canvas = document.createElement "canvas"
document.body.appendChild canvas

# canvas.setText "hey"
c = canvas.getContext "2d"
canvas.width = window.innerWidth
canvas.height = window.innerHeight

c.circle = (x,y,r)->
	c.beginPath()
	c.arc(x, y, r, 0, Math.PI*2, false)

c.clear = ->
	c.clearRect(0,0,canvas.width,canvas.height)

#gravity = .001
###
class Vertebra
	constructor: (x, y, n)->
		@position = {x:x, y:y}
		@velocity = {x:0, y:0}
		@force = {x:0, y:0}
		@n = n
		@weight = 1

	updatePosition: ->

		@position.x += @velocity.x
		@position.y += @velocity.y
		@velocity.x += @force.x
		@velocity.y += @force.y
		@force.x = 0
###
###
var Constraint = function(above, below, distance){
	@above = above
	@below = below
	@d = distance
}

Constraint.prototype.applyForce = function() {
 
	var dx = @below.position.x - @above.position.x
	var dy = @below.position.y - @above.position.y
	var d = Math.sqrt(dx*dx+dy*dy)
	dx *= (@d/d)
	dy *= (@d/d)
	var angle = Math.atan2(dy, dx)
	@below.force.x += @above.force.y * Math.sin(angle) + @above.force.x * Math.cos(angle)
	@below.force.y += @above.force.y * Math.cos(angle) + @above.force.x * Math.sin(angle) + @below.weight * gravity
//console.log("n=" + @below.n + " force.x="+@below.force.x + "force.y="+@below.force.y)
}
Constraint.prototype.applyConstraint = function() {
 
	var dx = @below.position.x - @above.position.x
	var dy = @below.position.y - @above.position.y
	var d = Math.sqrt(dx*dx+dy*dy)
	dx *= (@d/d)
	dy *= (@d/d)
//console.log("n="+@above.n + " dx="+dx + " dy="+dy)
	@above.position.x = @below.position.x - dx
	@above.position.y = @below.position.y - dy
	
}

var FixedPosition = function(v, x, y){
	@above = v
	@below = v
	@x = x
	@y = y
}

FixedPosition.prototype.applyForce = function() {
}
FixedPosition.prototype.applyConstraint = function() {
	@above.position.x = @x
	@above.position.y = @y
	
}
###

Particle::draw = ()->
	c.circle( @pos.x, @pos.y, 5 )
	c.fill()

spine = new VerletJS.Composite

head = new Particle(new Vec2(100, 25))
head.draw = ()->
	c.circle @pos.x, @pos.y, 20
	c.fill()
	c.beginPath()
	c.strokeStyle = "white"
	if(@happy)
		c.arc(@pos.x, @pos.y, 15, 0, Math.PI)
	else
		c.arc(@pos.x, @pos.y+50, 40, Math.PI*1.46, Math.PI*1.54)
	c.lineWidth = 3
	c.stroke()
	c.beginPath();
	c.arc(@pos.x-5, @pos.y, 4, 0, Math.PI*2)
	c.stroke()
	c.beginPath();
	c.arc(@pos.x+5, @pos.y, 4, 0, Math.PI*2)
	c.stroke()
	c.fillStyle = "green"

head.weight = 20
spine.particles.push(head)

for i in [0...24]
	#new Point(100-cos(i/24*TAU)*20, i*10+20, i)
	#new Particle(100-cos(i/24*TAU)*20, i*10+20, i)
	spine.particles.push new Particle(
#		new Vec2(100-cos(i/24*TAU)*20, i*10+20)
		new Vec2(100, i*10+45)
	)


#spine.push x: 100, y: 100

for i in [0...spine.particles.length-1]
	#new Constraint(spine[i], spine[i+1], force: 1.4, length: 10)
	spine.constraints.push new DistanceConstraint(
		spine.particles[i]
		spine.particles[i+1]
		5, spine.particles[i+1].pos.y - spine.particles[i].pos.y
	)

for i in [1...spine.particles.length-1]
	#new AngularConstraint(spine[i-1], spine[i], spine[i+1], force: 0.4)
	spine.constraints.push new AngleConstraint(
		spine.particles[i-1]
		spine.particles[i]
		spine.particles[i+1]
		2.5
	)

spine.constraints.push new PinConstraint(
	spine.particles[spine.particles.length-1]
	spine.particles[spine.particles.length-1].pos
)
spine.constraints.push new PinConstraint(
	spine.particles[spine.particles.length-2]
	spine.particles[spine.particles.length-2].pos
)

spine.constraints.push new AngleConstraint(
	spine.particles[24]
	spine.particles[23]
	spine.particles[11]
	2.5
)
spine.constraints.push new AngleConstraint(
	spine.particles[24]
	spine.particles[23]
	spine.particles[7]
	2.5
)
spine.constraints.push new AngleConstraint(
	spine.particles[24]
	spine.particles[23]
	spine.particles[0]
	2.5
)

###
for( var i = 0 i <  23 i++ )
{
	spine[i].constraint = new Constraint(spine[i], spine[i+1], 10)
}
spine[23].constraint = new FixedPosition(spine[23], 100+Math.cos(23/24*Math.PI)*20, 23*10+20)
###

sim = new VerletJS(640, 480, canvas)
sim.friction = 0.4
sim.highlightColor = "#0f0"
sim.composites.push(spine)


do animate = ->
	#constraint.update() for constraint in constraints
	#thing.update() for thing in things

	c.clear()

	sim.frame(16)
	sim.draw()

	c.fillStyle = "Green"

	head.happy = true
	threshold = 15
	bottom = spine.particles[spine.particles.length-1]
	for vertebra in spine.particles
		if (
			vertebra.pos.x < bottom.pos.x-threshold or
			vertebra.pos.x > bottom.pos.x+threshold
		)
			head.happy = false
	for vertebra in spine.particles
		vertebra.draw()
	
	canvas.style.position = "absolute"

	requestAnimationFrame(animate) if going

###
dragging = null

onMove = (e)->
	dragging?.x = e.offsetX
	dragging?.y = e.offsetY

onDown = (e) ->
	for vertebra in spine
		if( e.offsetX - 4 < vertebra.x < e.offsetX + 4 and
		    e.offsetY - 4 < vertebra.y < e.offsetY + 4 )
				dragging = spine[i]
				break

onUp = (e)->
	dragging = null

window.addEventListener "mousemove", onMove
window.addEventListener "mousedown", onDown
window.addEventListener "mouseup", onUp
###
step.onclick = ->
	going = no
	animate()
go.onclick = ->
	unless going
		going = yes
		animate()
