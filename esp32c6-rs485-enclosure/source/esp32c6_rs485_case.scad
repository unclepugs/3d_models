// Krabička pre ESP32-C6-DevKitC-1 + KAmodRS485-3V3 (pasívny odposluch EXOline).
// Voľne položená v rozvádzači, prepojenie dupont káblikmi, tlač PETG bez podpier.
//
// ESP32 leží vyvýšene na dvoch podperách (pod ním je miesto na dupont konektory
// na spodných pinoch), USB-C ústi otvorom v čelnej stene. KAmod leží na dne
// v rohových zarážkach, kábel zbernice ide otvorom v tej istej čelnej stene
// vedľa USB (svorky KAmod otočené k nej).
//
// Variant na DIN lištu 35 mm: samostatný klip (tlačí sa naplocho) priskrutkovaný
// zospodu dvoma skrutkami M3×10 so zápustnou hlavou do výstupkov v dne krabičky.
//
// Export: ./build.sh (STL + náhľady do ../freestanding a ../din-rail)
//   part = "body" | "lid" | "all"          voľne položená (telo + veko vedľa seba)
//        | "clip" | "all_din"              DIN: klip / telo s výstupkami + veko + klip
//        | "din_assembly"                  len náhľad zostavy na lište

part = "all";
din = false;           // telo s výstupkami pre skrutky klipu (part="all_din" ho zapne sám)

/* [Dosky] */
esp_l = 51.8;          // ESP32-C6-DevKitC-1
esp_w = 25.4;
pcb_t = 1.6;
usb_overhang = 1.0;    // o koľko USB-C konektory prečnievajú za hranu dosky
esp_z = 24;            // výška spodku dosky ESP32 nad dnom (dupont pod doskou)

kam_l = 61.2;          // KAmodRS485-3V3
kam_w = 20.3;

/* [Krabička] */
wall = 2.2;
floor_t = 2.0;
clr = 0.4;             // vôľa okolo dosiek
gap = 9;               // medzera medzi doskami (káble)
in_l = 77.6;           // vnútorná dĺžka → vonkajšia 82 mm
kam_shift = 0;         // posun KAmod od stredu (+ = od čelnej steny)
in_h = 36;             // vnútorná výška
r = 3;                 // zaoblenie rohov

/* [Veko] */
lid_t = 2.0;
lip_h = 3.0;
lip_t = 1.4;
lip_clr = 0.25;        // vôľa veka (PETG); ak drží voľne, zmenši na 0.15

/* [Otvory] */
usb_hole_w = 26;       // oba USB-C porty DevKitu
usb_hole_h = 6;
cable_d = 8;           // kábel zbernice (A, B, GND)

/* [DIN klip] */
clip_w = 50;           // šírka klipu pozdĺž lišty
clip_t = 3;            // hrúbka platne
clip_sx = 17;          // skrutky ±17 mm od stredu
rail_half = 17.5;      // TS35: polovica šírky lišty
rail_flange = 1.0;     // hrúbka plechu lišty
boss_h = 5;            // výstupky v dne pre skrutky (otvor 2,5 mm = samorez do PETG)

$fn = 48;

// --- odvodené rozmery ---
esp_x0 = usb_overhang + clr;              // začiatok dosky ESP32 (USB koniec)
esp_x1 = esp_x0 + esp_l;
esp_y0 = clr;
esp_y1 = esp_y0 + esp_w;
kam_y0 = esp_y1 + gap;
kam_y1 = kam_y0 + kam_w;
kam_x0 = (in_l - kam_l) / 2 + kam_shift;
in_w = kam_y1 + clr + 1;
out_l = in_l + 2 * wall;
out_w = in_w + 2 * wall;
out_h = floor_t + in_h;

module rrect(l, w, h, rr) {
  linear_extrude(h) offset(rr) offset(-rr) square([l, w]);
}

boss_y = (esp_y1 + kam_y0) / 2;          // v medzere medzi doskami
boss_xs = [in_l / 2 - clip_sx, in_l / 2 + clip_sx];

module body(with_din = din) {
  difference() {
    union() {
      body_base();
      if (with_din)
        for (x = boss_xs) translate([x, boss_y, floor_t]) cylinder(d = 7, h = boss_h);
    }
    if (with_din)
      for (x = boss_xs) translate([x, boss_y, -1]) cylinder(d = 2.5, h = floor_t + boss_h + 0.5);
  }
}

module body_base() {
  difference() {
    translate([-wall, -wall, 0]) rrect(out_l, out_w, out_h, r);
    translate([0, 0, floor_t]) rrect(in_l, in_w, in_h + 1, max(r - wall, 0.5));

    // USB-C
    translate([-wall - 1, (esp_y0 + esp_y1) / 2 - usb_hole_w / 2,
               floor_t + esp_z + pcb_t + 1.7 - usb_hole_h / 2])
      cube([wall + 2, usb_hole_w, usb_hole_h]);

    // kábel zbernice v čelnej stene vedľa USB, v osi KAmod
    translate([-wall - 1, (kam_y0 + kam_y1) / 2, floor_t + 9])
      rotate([0, 90, 0]) cylinder(d = cable_d, h = wall + 2);
  }

  translate([0, 0, floor_t]) {
    // podpery ESP32 – len v strede šírky, mimo pinových líšt pri okrajoch
    sy0 = esp_y0 + 3.5;
    sy1 = esp_y1 - 3.5;
    translate([0, sy0, 0]) cube([esp_x0 + 2.5, sy1 - sy0, esp_z]);
    translate([esp_x1 - 2.5, sy0, 0]) cube([2.5 + clr + 2, sy1 - sy0, esp_z]);
    // zarážka za koncom dosky
    translate([esp_x1 + clr, sy0, 0]) cube([2, sy1 - sy0, esp_z + pcb_t + 2]);
    // bočné vodiace rebrá (druhú stranu vedie stena krabičky)
    for (x = [esp_x0 + 1, esp_x1 - 5])
      translate([x, esp_y1 + clr, 0]) cube([4, 1.6, esp_z + pcb_t + 2]);

    // rohové zarážky KAmod
    for (cx = [0, 1], cy = [0, 1]) {
      x = cx ? kam_x0 + kam_l + clr : kam_x0 - clr;
      y = cy ? kam_y1 + clr : kam_y0 - clr;
      sx = cx ? 1 : -1;
      sy = cy ? 1 : -1;
      translate([x, y, 0]) {
        translate([cx ? 0 : -1.2, cy ? -5 : 0, 0]) cube([1.2, 5, 4]);
        translate([cx ? -5 : 0, cy ? 0 : -1.2, 0]) cube([5, 1.2, 4]);
        // spojenie rohu
        translate([cx ? 0 : -1.2, cy ? 0 : -1.2, 0]) cube([1.2, 1.2, 4]);
      }
    }
  }
}

module lid() {
  difference() {
    union() {
      translate([-wall, -wall, 0]) rrect(out_l, out_w, lid_t, r);
      // lem zapadne do krabičky
      translate([lip_clr, lip_clr, lid_t])
        difference() {
          rrect(in_l - 2 * lip_clr, in_w - 2 * lip_clr, lip_h, max(r - wall, 0.5));
          translate([lip_t, lip_t, -1])
            rrect(in_l - 2 * lip_clr - 2 * lip_t, in_w - 2 * lip_clr - 2 * lip_t, lip_h + 2, 0.5);
        }
    }
    // vetranie nad ESP32
    for (i = [0 : 4])
      translate([esp_x0 + 10 + i * 7, esp_y0 + 4, -1]) cube([2.5, esp_w - 8, lid_t + 2]);
    // nápis (veko sa tlačí hornou stranou na podložke → zrkadlovo)
    translate([in_l - 8, kam_y0 + kam_w / 2, -0.01])
      mirror([1, 0, 0]) linear_extrude(0.6)
        text("EXOline", size = 7, halign = "left", valign = "center", font = "Liberation Sans:style=Bold");
  }
}

// DIN klip v polohe "na lište": stred lišty y = 0, platňa z = 0..clip_t
// (z = 0 dosadá na lemy lišty), háčiky pod ňou (z < 0), x = 0..clip_w.
// Jeden okraj lišty chytí pevný háčik, druhý pružná západka na nosníku,
// ktorý sa ohýba v rovine vrstiev. Jazýček západky = vyberanie skrutkovačom.
module din_clip() {
  e = rail_half;
  pocket = rail_flange + 0.3;            // medzera pre plech lišty
  hz = pocket + 1.5;                     // hĺbka háčika (spodok pery)
  beam_y = e - 3;                        // pružný nosník nad lemom lišty
  lx0 = clip_w / 2 - 8;                  // západka 16 mm široká v strede
  screw_y = boss_y - in_w / 2;

  module yz_profile(len, pts) {          // polygon [y, z] vytiahnutý pozdĺž x
    rotate([90, 0, 90]) linear_extrude(len) polygon(pts);
  }

  difference() {
    union() {
      translate([0, -e - 4.5, 0]) cube([clip_w, e + 4.5 + beam_y - 2, clip_t]);
      // uchytenie nosníka na koncoch
      for (x = [0, clip_w - 4]) translate([x, beam_y - 2.5, 0]) cube([4, 3.5, clip_t]);
      // pružný nosník + krčok k západke
      translate([0, beam_y, 0]) cube([clip_w, 1.0, clip_t]);
      translate([clip_w / 2 - 2, beam_y + 1.0, 0]) cube([4, 1.0, clip_t]);
      // západka s jazýčkom
      translate([lx0, beam_y + 2.0, 0]) cube([16, e + 9 - beam_y - 2.0, clip_t]);
      translate([lx0, 0, 0]) yz_profile(16, [
        [e - 1.5, -pocket], [e - 1.5, -pocket - 0.5], [e - 0.5, -hz],
        [e + 2.5, -hz], [e + 2.5, 0], [e + 0.2, 0], [e + 0.2, -pocket]]);
      // pevný háčik po celej šírke
      yz_profile(clip_w, [
        [-e - 2.5, 0], [-e - 2.5, -hz], [-e + 1.2, -hz], [-e + 1.7, -hz + 0.5],
        [-e + 1.7, -pocket], [-e - 0.2, -pocket], [-e - 0.2, 0]]);
    }
    // zápustné skrutky M3 zo strany lišty (v priehlbine lišty)
    for (dx = [-clip_sx, clip_sx]) translate([clip_w / 2 + dx, screw_y, 0]) {
      translate([0, 0, -1]) cylinder(d = 3.4, h = clip_t + 2);
      translate([0, 0, -0.01]) cylinder(d1 = 6.6, d2 = 3.4, h = 1.6);
    }
  }
}

module din_clip_print() {               // platňou na podložke, háčiky hore
  translate([0, 0, clip_t]) rotate([180, 0, 0]) din_clip();
}

module ts35() {
  color("silver", 0.6) rotate([90, 0, 90]) linear_extrude(in_l + 20) polygon([
    [-17.5, 0], [-12.5, 0], [-12.5, -7.5], [12.5, -7.5], [12.5, 0], [17.5, 0],
    [17.5, -1], [13.5, -1], [13.5, -8.5], [-13.5, -8.5], [-13.5, -1], [-17.5, -1]]);
}

if (part == "body") body();
else if (part == "lid") lid();
else if (part == "clip") din_clip_print();
else if (part == "all_din") {
  body(true);
  translate([0, out_w + 8, 0]) lid();
  translate([in_l / 2 - clip_w / 2, -wall - 8 - (rail_half + 9), 0]) din_clip_print();
}
else if (part == "din_assembly") {
  body(true);
  translate([in_l / 2 - clip_w / 2, in_w / 2, -clip_t]) din_clip();
  translate([-10, in_w / 2, -clip_t]) ts35();
}
else {
  body();
  translate([0, out_w + 8, 0]) lid();
}
