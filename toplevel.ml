#directory "_build";;
#load "gtk_light.cmo";;
module Gui = Gtk_light
open Plcairo

let plcairo = plinit_cairo ~clear:true ~width:500 ~height:500 plimagecairo None

let stream =
  P.init ~size:(500, 500) 0.0 1.0 0.0 1.0 P.Greedy (P.External plcairo.plstream)

let redraw plot widget _ =
  plblit_to_cairo ~dest:(Cairo_lablgtk.create widget#misc#window)
    ~dim:(`width 500.0) ~xoff:0.0 ~yoff:0.0 plot;
  true

let plot_widget =
  Gui.drawing_area 500 500 ~callbacks:[Gui.expose_callback (redraw plcairo)]

(* Update the plot window approximately every 0.5 seconds until a signal is
   received which says otherwise. *)
let periodic_update continue plot_widget =
  let keep_going = ref true in
  while !keep_going do
    let continue_event = Event.receive continue in
    keep_going := Option.default true (Event.poll continue_event);
    Gui.queue_draw plot_widget;
    Thread.delay 0.5;
  done

let run_example () =
  let continue = Event.new_channel () in
  ignore (Thread.create (periodic_update continue) plot_widget);
  let w =
    Gui.window ~title:"Plot" plot_widget
      ~callbacks:[fun () -> Event.sync (Event.send continue false)]
  in
  Gui.show w;
  P.make_stream_active stream;
  pllab "x" "y" "title";
  let m = Array.Matrix.init 100 100 (fun i j -> foi i) in
  plimage m 0. 1. 0. 1. 0. 0. 0. 1. 0. 1.;
  P.finish_page 0. 0.;
  ()
