function addTextNode(text) {
  var newtext = document.createTextNode(text),
      p1 = document.getElementById("p1");

  p1.appendChild(newtext);

  
  };

var setText = function(element, text) {
if( "textContent" in Element.prototype )
  {
    element.textContent = text;
  }
  else
  {
    element.innerText = text;
  }

};

Element.prototype.setText = function(text) {
  setText(this,text);
};

var step = document.createElement("button");
step.setText("Step");
document.body.appendChild(step);

var go = document.createElement("button");
go.setText("Go");
document.body.appendChild(go);
var going = false;

var canvas = document.createElement("canvas");
document.body.appendChild(canvas);

//canvas.setText("hey");
var c = canvas.getContext("2d");
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

c.circle = function(x,y,r){
	c.beginPath();
	c.arc(x, y, r, 0, Math.PI*2, false);
	
};
c.clear = function(){
	c.clearRect(0,0,canvas.width,canvas.height);
};

var Vertebra = function(x, y, n){
	this.position = {x:x, y:y};
	this.velocity = {x:0, y:0};
	this.force = {x:0, y:0};
	this.n = n;
	this.weight = 1;
};

var gravity = .00001;

Vertebra.prototype.updatePosition = function(){

	this.position.x += this.velocity.x;
	this.position.y += this.velocity.y;
	this.velocity.x += this.force.x;
	this.velocity.y += this.force.y;
	this.force.x = 0;

};
Vertebra.prototype.applyForce = function(){
	if( this.constraint != null ) {
		this.constraint.applyForce();
	}
};


var Constraint = function(above, below, distance){
	this.above = above;
	this.below = below;
	this.d = distance;
};

Constraint.prototype.applyForce = function() {
 
	var dx = this.below.position.x - this.above.position.x;
	var dy = this.below.position.y - this.above.position.y;
	var d = Math.sqrt(dx*dx+dy*dy);
	dx *= (this.d/d);
	dy *= (this.d/d);
	var angle = Math.atan2(dy, dx);
	this.below.force.x += this.above.force.y * Math.sin(angle) + this.above.force.x * Math.cos(angle);
	this.below.force.y += this.above.force.y * Math.cos(angle) + this.above.force.x * Math.sin(angle) + this.below.weight * gravity;
//console.log("n=" + this.below.n + " force.x="+this.below.force.x + "force.y="+this.below.force.y);
};
Constraint.prototype.applyConstraint = function() {
 
	var dx = this.below.position.x - this.above.position.x;
	var dy = this.below.position.y - this.above.position.y;
	var d = Math.sqrt(dx*dx+dy*dy);
	dx *= (this.d/d);
	dy *= (this.d/d);
//console.log("n="+this.above.n + " dx="+dx + " dy="+dy);
	this.above.position.x = this.below.position.x - dx;
	this.above.position.y = this.below.position.y - dy;
	
};

var FixedPosition = function(v, x, y){
	this.above = v;
	this.below = v;
	this.x = x;
	this.y = y;
};

FixedPosition.prototype.applyForce = function() {
};
FixedPosition.prototype.applyConstraint = function() {
	this.above.position.x = this.x;
	this.above.position.y = this.y;
	
};


var spine = [];
for( var i = 0; i <  24; i++ )
{
	spine[i] = new Vertebra(100-Math.cos(i/24*Math.PI)*20, i*10+20, i);
}
for( var i = 0; i <  23; i++ )
{
	spine[i].constraint = new Constraint(spine[i], spine[i+1], 10);
}
spine[23].constraint = new FixedPosition(spine[23], 100+Math.cos(23/24*Math.PI)*20, 23*10+20);


var animate=function(){
	spine.forEach(function(vertebra){
		vertebra.force.y = gravity;
		vertebra.force.x = 0;
	});
	spine.forEach(function(vertebra){vertebra.applyForce()});
	var i = spine.length;
	do
	{
		spine[--i].constraint.applyConstraint();
	} while( i > 0 );
	spine.forEach(function(vertebra){vertebra.constraint.applyConstraint()});
	spine.forEach(function(vertebra){vertebra.updatePosition()});
	c.clear();
	c.fillStyle = "Green";
	spine.forEach(function(vertebra)
	{
		c.circle(vertebra.position.x, vertebra.position.y, 5);
		c.fill();
	});
	
	canvas.style.position = "absolute";
	//canvas.style.left = Math.random()*100+"%";
	//canvas.style.top = Math.random()*100+"%";
	if(going)
	{
		requestAnimationFrame(animate);
	}
};

var dragging = null;
var onMove = function(e){
	if(dragging != null){
		dragging.position.x = e.offsetX;
		dragging.position.y = e.offsetY;
	}
};

var onDown = function(e){
	for( var i = 0; i < spine.length; ++i )
	{
		if( spine[i].position.x > e.offsetX - 4 && spine[i].position.x < e.offsetX + 4 &&
		    spine[i].position.y > e.offsetY - 4 && spine[i].position.y < e.offsetY + 4 )
		{
			dragging = spine[i];
			break;
		}	
	}
};

var onUp = function(e){
	dragging = null;
};

window.addEventListener("mousemove", onMove);
window.addEventListener("mousedown", onDown);
window.addEventListener("mouseup", onUp);
//animate();

step.onclick = animate;
go.onclick = function(){ going = true; animate(); };
