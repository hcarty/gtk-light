(** A simple, coercible widget *)
type widget_t = GObj.widget

(** A basic Gtk+ window type *)
type window_t = GWindow.window

(** Convert a GObj.widget to a widget_t *)
external of_gobj_widget : GObj.widget -> widget_t = "%identity"

(** Cast everything to a simple widget form *)
let simplify w = w#coerce

(** Convert a widget_t to a Gtk+ widget *)
let to_gtk_widget w = GObj.as_widget w

(** The base Gtk+ window *)
let window ?callbacks ~title content =
  let w = GWindow.window ~title () in
  ignore (w#connect#destroy GMain.quit);
  Option.may (List.iter (fun f -> ignore (w#connect#destroy f))) callbacks;
  w#add content;
  w

(** Show a window *)
let show w = w#show ()

(** Given a set of windows, run the GUI! *)
let run windows =
  List.iter show windows;
  GMain.main ()

(** Queue up a widget for update.  Probably most useful in callbacks. *)
let queue_draw widget = GtkBase.Widget.queue_draw (to_gtk_widget widget)

(** Events support by this module.  Should be abstract. *)
type event_callback_t =
  | Any of (Gdk.Tags.event_type Gdk.event -> bool)
  | Button_press of (GdkEvent.Button.t -> bool)
  | Scroll of (GdkEvent.Scroll.t -> bool)
  | Expose of (GdkEvent.Expose.t -> bool)
  | Configure of (GdkEvent.Configure.t -> bool)

(** User-visible functions to create callbacks for each event type *)
let any_callback f x = Any (f x)
let button_callback f x = Button_press (f x)
let scroll_callback f x = Scroll (f x)
let expose_callback f x = Expose (f x)
let configure_callback f x = Configure (f x)

(** HIDDEN - For use in connecting callbacks to events *)
let connect_callback widget event_callback =
  let connect = widget#event#connect in
  (* Connect the callback to the event, ignoring the generated signal id *)
  let f ?e_add e_connection e_callback =
    ignore (e_connection ~callback:e_callback);
    Option.may (fun x -> widget#event#add [x]) e_add;
  in
  match event_callback with
  | Any a_f -> f connect#any a_f
  | Button_press b_f -> f ~e_add:`BUTTON_PRESS connect#button_press b_f
  | Scroll s_f -> f ~e_add:`SCROLL connect#scroll s_f
  | Expose e_f -> f ~e_add:`EXPOSURE connect#expose e_f
  | Configure c_f -> f connect#configure c_f
let connect_callbacks ?callbacks widget =
  Option.may (
    fun callbacks ->
      let callbacks = List.map (fun f -> f widget) callbacks in
      List.iter (fun callback -> connect_callback widget callback) callbacks;
  ) callbacks

(*
(** Event box, for capturing input events *)
let event_box ~callbacks contents =
  let e_box = GBin.event_box () in
  (* Add the given widgets to the event box *)
  List.iter (fun widget -> e_box#add widget#coerce) contents;
  (* Connect event callbacks to the event box *)
  List.iter (fun callback -> connect_callback e_box callback) callbacks;
  e_box
*)

(* Support for box building *)
let box f contents =
  let box = f () in
  List.iter box#add contents;
  simplify box

(** Vertical and horizontal boxes for widget packing *)
let vbox contents = box GPack.vbox contents
let hbox contents = box GPack.hbox contents

(** Drawing area *)
let drawing_area ?callbacks width height =
  let area = GMisc.drawing_area ~width ~height () in
  connect_callbacks ?callbacks area;
  simplify area

(** Slider *)
let slider ?callbacks ~lower ~upper ~step ~init orientation =
  let s = GRange.scale `HORIZONTAL ~draw_value:false () in
  s#adjustment#set_bounds ~lower ~upper ~step_incr:step ();
  s#adjustment#set_value init;
  Option.may (
    fun callbacks ->
      List.iter (
        fun callback ->
          ignore (s#connect#value_changed (fun () -> callback s))
      ) callbacks;
  ) callbacks;
  simplify s
