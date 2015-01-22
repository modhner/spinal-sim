
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

class Vertebra extends Particle

	img = E "img"
	img.addEventListener "load", draw
	img.src = "./images/normal-apview-lumbarspine.png"

	constructor: (pos, @width, @height)->
		super(pos)

	draw: ->
		#c.circle(@pos.x, @pos.y, 5)
		#c.fill "green"
		sx = 101
		sy = 176
		sw = 122
		sh = 94
		dw = @width
		dh = @height
		c.save()
		c.translate @pos.x, @pos.y
		
		i = spine.particles.indexOf @
		#if 0 < i < spine.particles.length-1
			#c.rotate angleof(spine.particles[i-1].pos, spine.particles[i].pos, spine.particles[i+1].pos)
		if 0 < i < spine.particles.length
			c.rotate TAU/4 + atan2(
				spine.particles[i-1].pos.y -
				spine.particles[i+0].pos.y
				spine.particles[i-1].pos.x -
				spine.particles[i+0].pos.x
			)

		
		c.globalCompositeOperation = "lighten"
		c.drawImage img, sx, sy, sw, sh, -dw/2, -dh/2, dw, dh
		c.restore()

class Skull extends Particle

	weight: 5
	width: 40
	height: 55

	img = E "img"
	img.addEventListener "load", draw
	img.src = "./images/skull.jpg"

	constructor: ->
		super
	draw: ->
		#c.circle(@pos.x, @pos.y, 5)
		#c.fill "green"
		sx = 101
		sy = 176
		sw = 122
		sh = 94
		dw = @width
		dh = @height
		c.save()
		c.translate @pos.x, @pos.y
		
		i = spine.particles.indexOf @
		c.rotate TAU/4 + atan2(
			spine.particles[i+0].pos.y -
			spine.particles[i+1].pos.y
			spine.particles[i+0].pos.x -
			spine.particles[i+1].pos.x
		)

		c.globalCompositeOperation = "lighten"
		c.drawImage img, -dw/2, -dh/3, dw, dh
		c.restore()

		###
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
		###


spine = new VerletJS.Composite

head = new Skull(new Vec2(100, 25))

spine.particles.push(head)

y = 45
spine.particles.push new Vertebra( new Vec2(100, y+=4), 14, 5 ) for i in [1..7] # Cervical (C1 – C7)
spine.particles.push new Vertebra( new Vec2(100, y+=7), lerp(18, 9, i/12), 7 ) for i in [1..12] # Thoractic (T1 – T12)
spine.particles.push new Vertebra( new Vec2(100, y+=10), lerp(9, 18, i/5), 10 ) for i in [1..5] # Lumbar (L1 – L5)
spine.particles.push new Vertebra( new Vec2(100, y+=4), lerp(24, 3, i/5), 4 ) for i in [1..5] # Sacrum (S1 – S5)
#spine.particles.push new Particle new Vec2 100, y+=10 for i in [1..3] # Coccyx
console.log spine.particles.length

for i in [0...spine.particles.length-1]
	spine.constraints.push new DistanceConstraint(
		spine.particles[i]
		spine.particles[i+1]
		5 #, spine.particles[i+1].pos.y - spine.particles[i].pos.y
	)

for i in [1...spine.particles.length-1]
	spine.constraints.push new AngleConstraint(
		spine.particles[i-1]
		spine.particles[i]
		spine.particles[i+1]
		2.5
	)
for i in [1...spine.particles.length-1]
	spine.constraints.push new AngleConstraint(
		spine.particles[spine.particles.length-1]
		#spine.particles[spine.particles.length-2]
		spine.particles[i]
		spine.particles[0]
		0.01
	)


for i in [spine.particles.length-6..spine.particles.length-1]
	spine.constraints.push new PinConstraint(
		spine.particles[i]
		spine.particles[i].pos
	)

sim = new VerletJS(640, 480, canvas)
sim.friction = 0.01
sim.highlightColor = "#0f0"
sim.composites.push(spine)


draw = ->

	c.clear()
	#sim.draw()

	for vertebra in spine.particles
		vertebra.draw()

do animate = ->

	sim.frame(16)

	head.happy = true
	threshold = 15
	bottom = spine.particles[spine.particles.length-1]
	for vertebra in spine.particles
		if (
			vertebra.pos.x < bottom.pos.x-threshold or
			vertebra.pos.x > bottom.pos.x+threshold
		)
			head.happy = false
	
	draw()
	requestAnimationFrame(animate) if going


step.onclick = ->
	going = no
	animate()

go.onclick = ->
	unless going
		going = yes
		animate()
