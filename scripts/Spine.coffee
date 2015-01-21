
step = E "button"
step.setText "Step"
document.body.appendChild step

go = E "button"
go.setText "Go"
document.body.appendChild go
going = yes

canvas = new Canvas
document.body.appendChild canvas

c = canvas.getContext "2d"
canvas.width = window.innerWidth
canvas.height = window.innerHeight

Particle::draw = ->
	c.circle(@pos.x, @pos.y, 5)
	c.fill "green"

spine = new VerletJS.Composite

head = new Particle(new Vec2(100, 25))
head.draw = ->
	
	c.circle @pos.x, @pos.y, 20
	c.fill "green"
	c.beginPath()
	
	if @happy
		c.arc(@pos.x, @pos.y, 15, 0, TAU/2)
	else
		c.arc(@pos.x, @pos.y+50, 40, Math.PI*1.46, Math.PI*1.54)
	
	c.lineWidth = 3
	c.stroke "white"
	c.beginPath()
	c.arc(@pos.x-5, @pos.y, 4, 0, TAU)
	c.stroke "white"

	c.beginPath()
	c.arc(@pos.x+5, @pos.y, 4, 0, TAU)
	c.stroke "white"

head.weight = 20
spine.particles.push(head)

for i in [0...24]
	spine.particles.push new Particle(
		new Vec2(100, i*10+45)
	)

for i in [0...spine.particles.length-1]
	spine.constraints.push new DistanceConstraint(
		spine.particles[i]
		spine.particles[i+1]
		5, spine.particles[i+1].pos.y - spine.particles[i].pos.y
	)

for i in [1...spine.particles.length-1]
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

sim = new VerletJS(640, 480, canvas)
sim.friction = 0.4
sim.highlightColor = "#0f0"
sim.composites.push(spine)


do animate = ->

	c.clear()

	sim.frame(16)
	sim.draw()

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


step.onclick = ->
	going = no
	animate()

go.onclick = ->
	unless going
		going = yes
		animate()
