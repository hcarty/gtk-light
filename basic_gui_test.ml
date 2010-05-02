(* A simple test GUI for the Gtk_light library *)
open Gtk_light

(** Draw a line diagonally across the entire given drawing area. *)
let widget_exposed area _ =
  let drawable = area#misc#window in
  let gc = Gdk.GC.create drawable in
  let { Gtk.width = width; Gtk.height = height } = area#misc#allocation in
  Gdk.Draw.line drawable gc 0 0 width height;
  true

let () =
  (* The window will contain two drawing areas, one next to the other. *)
  let window_content =
    hbox [
      drawing_area 200 200 ~callbacks:[
        expose_callback widget_exposed;
      ];
      drawing_area 200 200 ~callbacks:[
        expose_callback widget_exposed;
      ];
    ]
  in
  (* Make the window and run the main Gtk+ loop *)
  let w = window ~title:"Gtk_light Test" window_content in
  run [w]
