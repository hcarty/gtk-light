module Gui = Gtk_light
open React
open Plcairo

let init_stream width height =
  let plcairo =
    plinit_cairo ~clear:true (width, height) plimagecairo
  in
  let stream =
    P.init ~size:(width, height) (0.0, 0.0) (1.0, 1.0) P.Greedy
      (P.External (plget_stream plcairo))
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
    let (_, cairo) = S.value plot in
    let plwidth, plheight = plget_dims cairo in
    if plwidth <> foi widget_width || plheight <> foi widget_height then (
      end_plot plot;
      set_plot (init_stream widget_width widget_height);
      draw_plot plot;
    );
    let scale_by =
      if widget_width < widget_height then
        `width (foi widget_width)
      else
        `height (foi widget_height)
    in
    plblit_to_cairo ~scale_by cairo (Cairo_lablgtk.create widget#misc#window);
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
