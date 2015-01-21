
{@abs, @pow, @sin, @cos, @atan2, @sqrt, @min, @max, @PI} = Math
@TAU = PI * 2

@distance = (a, b, c, d)->
	if d?
		[x1, y1, x2, y2] = [a, b, c, d]
	else
		[x1, y1, x2, y2] = [a.x, a.y, b.x, b.y]
	
	dx = x1 - x2
	dy = y1 - y2
	d = sqrt(dx*dx + dy*dy)

@sign = (x)->
	if x > 0
		+1
	else if x < 0
		-1
	else
		0

@lerp = (a, b, x)-> a + (b-a)*x
@sinerp = (a, b, x)-> lerp a, b, (sin(x) + 1) / 2
@coserp = (a, b, x)-> lerp a, b, (cos(x) + 1) / 2

@angleof = (a, b, c, d, e, f)->
	if f?
		[x1, y1, x2, y2, x3, y3] = [a, b, c, d, e, f]
	else
		[x1, y1, x2, y2, x3, y3] = [a.x, a.y, b.x, b.y, c.x, c.y]
	
	lpx = x1 - x2
	lpy = y1 - y2
	rpx = x3 - x2
	rpy = y3 - y2
	
	atan2(
		lpx*rpy - lpy*rpx
		lpx*rpx + lpy*rpy
	)