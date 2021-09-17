use <text_on/text_on.scad>

/* [Puzzle Props] */

// depth of the puzzle
puzzle_depth = 5;

// margin surrounding trackable code
vertical_margin = 1.2;

/* [Text Props] */

// size of text
text_size = 8;

// trackable id for this puzzle (public value)
trackable_id = "TB12345";

// trackable code for this puzzle (private value)
trackable_code = "TC1234";

/* [Render Options] */

// cut in half for debugging
cut_in_half = false;

// smoother renders slower
quality = 8; //[2:Draft, 4:Medium, 8:Fine, 16:Ultra Fine]

/* [Hidden] */

// print quality settings
$fa = 12 / quality;
$fs = 2 / quality;

puzzle_height = text_size + 4;
puzzle_width = text_size * (len(trackable_id) + len(trackable_code));

module puzzle() {
  hull() {
    translate([-puzzle_width / 2, 0, 0])
      cylinder(r = puzzle_height / 2, h = puzzle_depth, center = true);

    translate([puzzle_width / 2, 0, 0])
      cylinder(r = puzzle_height / 2, h = puzzle_depth, center = true);
  }
}

difference() {
  puzzle();

  // keyring hole
  translate([-puzzle_width / 2, 0, 0])
    cylinder(r = puzzle_height / 4, h = puzzle_depth, center = true);

  // trackable id
  translate([-(puzzle_width - len(trackable_id) * text_size) / 2, 0, puzzle_depth / 2])
    text_extrude(t = trackable_id, size = text_size, extrusion_height = puzzle_height / 2, center = true);

  // trackable code
  translate([(puzzle_width - len(trackable_code) * text_size) / 2, 0, 0])
    text_extrude(t = trackable_code, size = text_size, extrusion_height = puzzle_depth - vertical_margin * 2, center = true);

  if (cut_in_half) {
    translate([0, -puzzle_height, 0])
      cube([puzzle_width * 2, puzzle_height * 2, puzzle_depth], center = true);
  }
}
