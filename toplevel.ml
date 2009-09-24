#directory "_build";;
#load "gtk_light.cmo";;
module Gui = Gtk_light
open Plcairo

let init_stream width height =
  let plcairo =
    plinit_cairo ~clear:true ~width ~height plimagecairo None
  in
  let stream =
    P.init ~size:(width, height) (0.0, 0.0) (1.0, 1.0) P.Greedy
      (P.External plcairo.plstream)
  in
  stream, plcairo

let create_stream width height =
  S.create (init_stream width height)

let image =
  Array.Matrix.init 200 200 (fun i j -> foi i)

let draw_plot plot =
  P.make_stream_active (fst (S.value plot));
  pllab "x" "y" "title";
  plimage image 0. 1. 0. 1. 0. 0. 0. 1. 0. 1.;
  P.finish_page 0. 0.;
  ()

let end_plot plot =
  P.make_stream_active (fst (S.value plot));
  plend1 ();
  ()

let redraw plot set_plot widget expose_event =
  if GdkEvent.Expose.count expose_event = 0 then (
    let { Gtk.width = widget_width; Gtk.height = widget_height } =
      widget#misc#allocation
    in
    let cairo = snd (S.value plot) in
    if cairo.width <> foi widget_width || cairo.height <> foi widget_height then (
      end_plot plot;
      set_plot (init_stream widget_width widget_height);
      draw_plot plot;
    );
    let dim =
      if widget_width < widget_height then
        `width (foi widget_width)
      else
        `height (foi widget_height)
    in
    plblit_to_cairo ~dest:(Cairo_lablgtk.create widget#misc#window)
      ~dim ~xoff:0.0 ~yoff:0.0 (snd (S.value plot));
  );
  true

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
  let width, height = 500, 500 in
  let plot, set_plot = create_stream width height in

  let plot_widget =
    Gui.drawing_area width height
      ~callbacks:[Gui.expose_callback (redraw plot set_plot)]
  in

  let continue = Event.new_channel () in
  ignore (Thread.create (periodic_update continue) plot_widget);
  let w =
    Gui.window ~title:"Plot" plot_widget
      ~callbacks:[fun () -> Event.sync (Event.send continue false)]
  in
  Gui.show w;
  draw_plot plot;
  ()
