use <text_on/text_on.scad>

/* [Coin Props] */

// logo image source
image_source = "geocaching_logo_inverted.svg";

// radius of coin
coin_radius = 15;

// height of coin
coin_height = 3;

// image margin around edge of coin
coin_margin = 1;

// the inset of the text area
coin_inset = .8;

/* [Text Props] */

// size of text
text_size = 3.5;

// text at the top of the coin
top_text = " ";

// text at center of coin
center_text = " ";

// text at bottom
bottom_text = " ";

/* [Render Options] */

// smoother renders slower
quality = 8; //[2:Draft, 4:Medium, 8:Fine, 16:Ultra Fine]

// disable to speed test rendering
render_surface = true;

/* [Hidden] */

// print quality settings
$fa = 12 / quality;
$fs = 2 / quality;

coin_diameter = coin_radius * 2;
coin_inner_radius = coin_radius - coin_margin;

difference() {
  cylinder(h = coin_height, r = coin_radius);

  translate([0, 0, coin_height])
    cylinder(h = coin_inset * 2, r = coin_inner_radius, center = true);

  if (render_surface) {
    intersection() {
      linear_extrude(height = 1)
        resize([coin_diameter, coin_diameter])
          mirror([1, 0, 0])
            import(image_source, center = true);

      cylinder(h = coin_height, r = coin_inner_radius);
    }
  }
}

translate([0, 0, coin_height - coin_inset / 2]) {
  text_margin = text_size / 2 + coin_margin;

  text_on_circle(t = top_text, r = coin_inner_radius - text_margin, size = text_size, extrusion_height = coin_inset);
  text_extrude(t = center_text, size = text_size, extrusion_height = coin_inset);
  text_on_circle(t = bottom_text, r = coin_inner_radius - text_margin, size = text_size, extrusion_height = coin_inset, ccw = true);
}
