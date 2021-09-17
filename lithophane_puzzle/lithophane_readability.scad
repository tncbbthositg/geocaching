use <text_on/text_on.scad>

/* [Sample Props] */

// depth of the samples
sample_depth = 5;

// minimum layer count
min_layer_count = 3;

// maximum layer count
max_layer_count = 6;

// intended layer height
layer_height = 0.2;

/* [Text Props] */

// size of text
text_size = 8;

// text margin
margin = 2;

/* [Render Options] */

// shave side for debugging
shave_side = false;

// shave top for debugging
shave_top = false;

// smoother renders slower
quality = 8; //[2:Draft, 4:Medium, 8:Fine, 16:Ultra Fine]

/* [Hidden] */

// print quality settings
$fa = 12 / quality;
$fs = 2 / quality;

segment_height = text_size + margin;
segment_width = text_size * 3;
segment_count = max_layer_count - min_layer_count + 1;

gap_height = segment_height - 2 * margin;
gap_depth = sample_depth - 2 * margin;

function toString(decimal) =
  (decimal % 1 == 0) ? str(decimal, ".0") : str(decimal);

module sample_text(vertical_margin) {
  margin_text = toString(vertical_margin);
  text_extrude(t = margin_text, size = text_size, spacing = .8, extrusion_height = sample_depth - vertical_margin * 2, center = true);
}

module segment(layer_count, inverse) {
  translate_direction = inverse ? -1 : 1;
  vertical_margin = layer_count * layer_height;

  translate_to = (segment_width / 2 + segment_width * (layer_count - min_layer_count)) * translate_direction;

  translate([translate_to, 0, 0]) {
    difference() {
      cube([segment_width, segment_height, sample_depth], center = true);

      if (inverse) {
        cube([segment_width - 2, segment_height - 1, sample_depth - vertical_margin * 2], center = true);
      } else {
        sample_text(vertical_margin);
      }
    }

    if (inverse) {
      sample_text(vertical_margin);
    }
  }
}

difference() {
  union() {
    for (i = [min_layer_count : max_layer_count]) {
      segment(i, false);
      segment(i, true);
    }
  }

  total_width = segment_count * segment_width * 2;
  if (shave_side) {
    translate([0, -segment_height / 2, 0])
      cube([total_width * 1.1, segment_height, sample_depth * 1.1], center = true);
  }

  if (shave_top) {
    translate([0, 0, sample_depth / 2])
      cube([total_width * 1.1, segment_height * 1.1, sample_depth], center = true);
  }
}