open Batteries
open Plplot
open Plcairo
module P = Plot
module G = Gtk_light

(** Get a Cairo context from the Gtk drawing area. *)
let get_cairo area =
  Cairo_lablgtk.create area#misc#window

module Widget_funcs = struct
  (** Redraw the plot contents on an expose event. *)
  let redraw area plcairo _ =
    let cr = get_cairo area in
    let { Gtk.width = width ; Gtk.height = height } = area#misc#allocation in
    let width = float_of_int width in
    let height = float_of_int height in
    plblit_to_cairo ~scale_by:(`both (width, height)) plcairo cr;
    false
end

let main =
  (* How large (device units) should the plot itself be? *)
  let plot_width = 500 in
  let plot_height = 500 in

  (* How large (pixels) should the GUI view of the plot be? *)
  let gui_width = plot_width in
  let gui_height = plot_height in

  (* Make a simple plot of the continents. *)
  let world_map =
    plinit_cairo ~clear:true (plot_width, plot_height) plimagecairo
  in
  let map_plot =
    P.init (0.0, 0.0) (1.0, 1.0) P.Greedy (P.External (plget_stream world_map))
  in
  let m =
    Array.init 100 (fun i -> Array.init 100 (fun j -> float_of_int (i + j)))
  in
  P.plot ~stream:map_plot [
    P.image (0.0, 0.0) (1.0, 1.0) m;
    P.label "X" "Y" "Colors!";
    P.default_axes;
  ];

  let exposed area x =
    Widget_funcs.redraw area world_map x
  in

  let window_contents =
    G.drawing_area gui_width gui_height ~callbacks:[
      G.expose_callback exposed;
    ]
  in
  (* Create a window for the app. *)
  let window = G.window ~title:"A simple plot" window_contents in

  (* Run the GUI until the user quits (closes the window) *)
  G.run [window];

  (* Now the plotting can end *)
  plend ();
  ()

