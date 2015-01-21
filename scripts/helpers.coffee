
@Canvas = ->
	canvas = document.createElement "canvas"
	ctx = canvas.ctx = canvas.getContext "2d"
	
	ctx.fill = (color)->
		ctx.fillStyle = color if color
		CanvasRenderingContext2D::fill.apply ctx, []

	ctx.stroke = (color)->
		ctx.strokeStyle = color if color
		CanvasRenderingContext2D::stroke.apply ctx, []

	ctx.line = (a, b, c, d)->
		if d?
			[x1, y1, x2, y2] = [a, b, c, d]
		else
			[x1, y1, x2, y2] = [a.x, a.y, b.x, b.y]
		
		ctx.beginPath()
		ctx.moveTo(x1, y1)
		ctx.lineTo(x2, y2)

	ctx.polygon = (points)->
		ctx.beginPath()
		ctx.lineTo(p.x, p.y) for p in points
		ctx.closePath()
	
	canvas

@destroy = (thing)->
	thing?.destroy?()
	for array in arraysofstuff
		i = array.indexOf thing
		array.splice(i, 1) if i >= 0

@nearest = (Class, {from})->
	if Class isnt Point then throw new Error "unsupported"
	# This helper could be extended in the future to allow searching for
	# FixedPoints (currently just plain Objects) and even (types of) Actors
	# Currently it only looks in `points` and only checks the type at the top
	nearest = null
	nearestdistance = Infinity
	for point in points when distance(from, point) < nearestdistance
		nearest = point
		nearestdistance = distance(from, point)
	nearest

@choose = (args...)->
	arr = if args.length > 1 then args else args[0]
	arr[~~(Math.random()*arr.length)]

@chance = (x)->
	unless 0 <= x <= 1 then throw new Error "chance must be between 0 and 1"
	Math.random() < x
