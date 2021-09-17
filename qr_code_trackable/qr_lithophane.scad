use <text_on/text_on.scad>

/* [Puzzle Props] */

// qr code image source
qr_code = "qr_code.svg";

// size of the puzzle
puzzle_width = 50;

// margin around puzzle
puzzle_margin = 1.8;

// height of the puzzle
puzzle_depth = 5;

// vertical margin covering qr code
vertical_margin = .8;

// border radius
border_radius = 2;

// is qr code completely enclosed? (the QR code would probably have to be huge for this to work well)
is_covered = false;

/* [Text Props] */

// depth of text
text_depth = 2;

// trackable code for this puzzle
trackable_code = "TB12345";

/* [Logo Options] */

// logo image source
logo_image_source = "geocaching_logo_dude.svg";

/* [Render Options] */

// smoother renders slower
quality = 8; //[2:Draft, 4:Medium, 8:Fine, 16:Ultra Fine]

// shave the top off for debugging
shave_top = false;

/* [Hidden] */

// print quality settings
$fa = 12 / quality;
$fs = 2 / quality;

half_root_two = sqrt(2) / 2;

text_size = (puzzle_width - 2 * puzzle_margin) / (len(trackable_code) + 1) * 1.1;
logo_size = text_size;

puzzle_height = puzzle_width + logo_size + puzzle_margin;

module puzzle_container() {
  lateral_translation = puzzle_width / 2 - border_radius;
  vertical_translation = puzzle_height / 2 - border_radius;

  hull() {
    for (i = [0 : 3]) {
      angle = i * 90 + 45;

      x = cos(angle) / half_root_two * lateral_translation;
      y = sin(angle) / half_root_two * vertical_translation;

      translate([x, y, 0])
        cylinder(r = border_radius, h = puzzle_depth);
    }
  }
}

module logo() {
  translate([-puzzle_width / 2 + puzzle_margin, -puzzle_height / 2 + puzzle_margin, puzzle_depth - text_depth])
    linear_extrude(height = puzzle_depth)
      resize([logo_size, logo_size])
        import(logo_image_source);
}

module trackable_code() {
  translate([puzzle_width / 2 - puzzle_margin, -puzzle_height / 2 + puzzle_margin, puzzle_depth - text_depth])
    text_extrude(t = trackable_code, size = text_size, extrusion_height = puzzle_depth, center = false, halign = "right");
}

module qr_code() {
  qr_code_vertical_margin = (is_covered ? 2 : 1) * vertical_margin;
  qr_code_depth = puzzle_depth - qr_code_vertical_margin;

  qr_code_container_size = puzzle_width - 2 * puzzle_margin;
  qr_code_size = qr_code_container_size - 2 * puzzle_margin;

  translate([0, puzzle_height / 2 - qr_code_container_size / 2 - puzzle_margin, vertical_margin])
    difference() {
      color("white")
        translate([0, 0, qr_code_depth / 2])
          cube([qr_code_container_size, qr_code_container_size, qr_code_depth], center = true);

      color("black")
          linear_extrude(height = qr_code_depth)
            resize([qr_code_size, qr_code_size])
              import(qr_code, center = true);
    }
}

difference() {
  puzzle_container();

  qr_code();
  color("green") logo();
  color("red") trackable_code();

  if (shave_top) {
    translate([0, 0, puzzle_depth])
      cube([2 * puzzle_width, 2 * puzzle_height, puzzle_depth], center = true);
  }
}
