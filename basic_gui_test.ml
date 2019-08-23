(* A simple test GUI for the Gtk_light library *)
open Gtk_light

(** Print the selected string to the terminal *)
let selected s =
  match s with
  | None -> ()
  | Some message -> print_endline message

let () =
  (* The window will contain two drawing areas, one next to the other. *)
  let window_content =
    vbox [
      combo_box_text ~callbacks:[selected] ["Entry 1"; "Entry 2"];
      hbox [
        combo_box_text ["Top box"];
        combo_box_text ["Bottom box"];
      ];
    ]
  in
  (* Make the window and run the main Gtk+ loop *)
  let w = window ~title:"Gtk_light Test" window_content in
  run [w]
