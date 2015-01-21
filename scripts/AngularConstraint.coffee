
class @AngularConstraint
	
	constructor: (@a, @b, @c, options)->
		constraints.push @
		things.push @
		@angle ?= options?.angle ? angleof(@a, @b, @c)
		@force ?= options?.force ? 5
		@color = "rgba(255, 0, 255, 0.4)"
	
	update: ->
		diff = angleof(@a, @b, @c) - @angle;
		
		if diff <= -PI
			diff += TAU
		else if diff >= PI
			diff -= TAU
		
		rot = (point, origin, theta)=>
			x = point.x - origin.x
			y = point.y - origin.y
			newx = x*cos(theta) - y*sin(theta) + origin.x
			newy = x*sin(theta) + y*cos(theta) + origin.y
			
			dx = newx - point.x
			dy = newy - point.y
			d = sqrt(dx*dx + dy*dy)
			divisor = if d < 1 then 1 else d
			f = @force / 10
			fx = dx/divisor * f
			fy = dy/divisor * f
			point.fx += fx
			point.fy += fy
		
		rot @a, @b, +diff
		rot @c, @b, -diff
		rot @b, @a, +diff
		rot @b, @c, -diff
	
	# draw: ->
	# 	ctx.beginPath()
	# 	ctx.arc(@b.x, @b.y, distance(@b, @a)/2, 0, TAU, no)
	# 	ctx.stroke @color
	# 	
	# 	ctx.beginPath()
	# 	ctx.arc(@b.x, @b.y, distance(@c, @a)/2, 0, TAU, no)
	# 	ctx.stroke @color
