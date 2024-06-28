
// Outer diameter 
D = 111.3; 
// Ring thickness
d = 15.01;  
// Notch width
s = 1.84;  
// Angle for the feedpoint section
alpha = 14.2; 
// Substrate height
substrate_height = 5.01; 
// how large is the angle of the inner ring cut
inner_ring_cut_angle = 5.01; 

// Sector module to create a filled sector between two angles
module sector(radius, angles, fn = 100) {
    r = radius / cos(180 / fn);
    step = -360 / fn;

    points = concat([[0, 0]],
        [for(a = [angles[0] : step : angles[1] - 360]) 
            [r * cos(a), r * sin(a)]
        ],
        [[r * cos(angles[1]), r * sin(angles[1])]]
    );

    difference() {
        circle(radius, $fn = fn);
        polygon(points);
    }
}

// Arc module to create an arc with a specified thickness between two angles
module arc(radius, angles, width = 1, fn = 100) {
    difference() {
        sector(radius + width / 2, angles, fn);
        sector(radius - width / 2, angles, fn);
    }
}

// Small sector subtraction module
module small_sector(radius, angles, fn = 100) {
    sector(radius, angles, fn);
}

module ring_segment(D, d, s, alpha) {
    outer_radius = D / 2;
    inner_radius = outer_radius - d;
    marker_radius = (d-s)/8; // Diameter of markers is s/4, so radius is s/8

    // Main ring
    difference() {
        circle(outer_radius, $fn=100);
        circle(inner_radius, $fn=100);

        // Subtract the semi-circular notch (quarter ring) from 180 to 270 degrees
        arc((inner_radius + outer_radius) / 2, [180, 270], s, fn=100);

        // Subtract the smaller sector at 180 degrees to intersect with the notch
        small_sector((inner_radius + outer_radius) / 2, [180, 180+inner_ring_cut_angle], fn=100);

        // Subtract feedpoint markers
        rotate([0, 0, -90]) {
            angle = alpha;
            rotate([0, 0, -angle]) {
                translate([outer_radius-marker_radius*2, 0])
                circle(marker_radius, $fn=100);
                translate([inner_radius+marker_radius*2, 0])
                circle(marker_radius, $fn=100);
            }
        }
    }
}

// Extrude the 2D shape to the specified substrate height
linear_extrude(height = substrate_height)
    ring_segment(D, d, s, alpha);
