(* A simple test GUI for the Gtk_light library *)
open Batteries
open Gtk_light

(** Draw a line diagonally across the entire given drawing area. *)
let widget_exposed area _ =
  let drawable = area#misc#window in
  let gc = Gdk.GC.create drawable in
  let { Gtk.width = width; Gtk.height = height } = area#misc#allocation in
  Gdk.Draw.line drawable gc 0 0 width height;
  true

(** Print the selected string to the terminal *)
let selected s =
  Option.may print_endline s

let () =
  (* The window will contain two drawing areas, one next to the other. *)
  let window_content =
    vbox [
      combo_box_text ~callbacks:[selected] ["Entry 1"; "Entry 2"];
      hbox [
        drawing_area 200 200 ~callbacks:[
          expose_callback widget_exposed;
        ];
        drawing_area 200 200 ~callbacks:[
          expose_callback widget_exposed;
        ];
      ];
    ]
  in
  (* Make the window and run the main Gtk+ loop *)
  let w = window ~title:"Gtk_light Test" window_content in
  run [w]
