// number of lambdas
num = 6; // [3:25]

// Offset of lambda
foff = [-22.3, -37];

// Offset after clipping. Use for gaps.
gaps = [0, -2.60];

// rotation of each lambda
lrot = 0; // [-180:180]

// lambda arm angle
larm = 30; // [-180:180]

// Clipping ngon radius
clipr = 90.82; // [0:300]
// Clipping ngon rotation
cliprot = 0;  // [-180:180]

// lambda thickness
thick = 17; // [5:100]

// remove this parameter if you want to update Thingiverse project 
// colors to use
colors = ["#5277c3", "#7caedc"];

// inverse clipping order
invclip = false;

show_full = true;


// Pin/hole size ratio


// copied from <MCAD/regular_shapes.scad> so customizer will work on thingieverse
module regular_polygon(sides, radius)
{
    function dia(r) = sqrt(pow(r*2,2)/2);  //sqrt((r*2^2)/2) if only we had an exponention op
    angles=[ for (i = [0:sides-1]) i*(360/sides) ];
    coords=[ for (th=angles) [radius*cos(th), radius*sin(th)] ];
    polygon(coords);
}

// draw a 2D lambda
module lambda() {
    union() {
        rotate(-larm) translate([0,-25]) square([thick,50], center=true);
        rotate(larm) square([thick,100], center=true);
    }    
}

module debugdiff(debug = false){
    if (!debug)
        difference() { 
            children(0);
            children(1);
        }
    else{
        union() { 
            difference() { 
                children(0);
                children(1);
            };
            children(1);
        }
    }
}
// generates lambda and subtracts next lambda from it
module diff(nextangle, debug=false) {
    debugdiff(debug) {
        children();
        color("red")
        rotate(invclip ? nextangle : -nextangle) children();
    }
}

module clipper(){
    // that's not as easy to autotune as it would seem
    intersection() {
        rotate(cliprot) regular_polygon(num, clipr);
        children();
    }    
}

//rotate([70,8,0])
// render the logo!
if (show_full)
union() {
    // just do that N times
    for (r=[0:num-1])
    // color it with next color in array
    color(colors[r % len(colors)])
    // linear_extrude(1)
    // flatten before coloring
    // final rotation, putting lambda in place
    rotate(360/num*r)
    
    clipper()
    translate(gaps)
    // clip the edges
    // cutting it up with the same lambda at the next place
    diff(360/num)
    // translation to endpoint
    translate(foff)
    // initial in-place rotation
    rotate(lrot)
    lambda();
}

module make_pin(scl = 1, r = pin_r) {
    translate(foff + gaps)
    
    rotate(lrot)
    rotate(larm)
    
    translate([+0,30,10])
    
    rotate([90,45])
    scale(scl)
    cube([r * 2, r * 2, pin_l], center=true);
    //cylinder(50, r, r, center=true);
}