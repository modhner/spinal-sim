
class @Point
	
	constructor: (@x, @y)->
		points.push @
		things.push @
		@vx = 0
		@vy = 0
		@fx = 0
		@fy = 0
		@gravity = 0.05
		@airfriction = 0.01
		@friction = 0.7
	
	update: ->
		@vx /= (@airfriction + 1)
		@vy += @gravity
		@x += @vx += @fx
		@y += @vy += @fy
		@fx = 0
		@fy = 0
		
		###
		# @TODO have constraints collide as well
		for solid in solids
			if solid.collision(@x, @y)
				@y -= @vy+0.1 # @FIXME magic number
				@vy = -abs(@vy)/5
				@vx /= (@friction + 1)
				# @TODO non-vertical collision with surfaces
		###
