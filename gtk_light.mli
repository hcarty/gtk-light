(** Abstract widget and window types *)
type widget_t
type window_t

(** Cast un-wrapped GObj widgets to the appropriate widget form.  This provides
    a simple, if unclean, work-around for widgets which have not been wrapped
    yet. *)
val of_gobj_widget : GObj.widget -> widget_t

(** Cast widget_t widgets to Gtk.widget Gtk.obj values *)
val to_gtk_widget : widget_t -> Gtk.widget Gtk.obj

(** Create a GUI window, containing one widget.  When the window is closed it
    will automatically end the GUI loop. *)
val window :
  ?callbacks:(unit -> unit) list -> title:string -> widget_t -> window_t

(** Show a window *)
val show : window_t -> unit

(** Given a list of windows, show them and run the main Gtk+ loop *)
val run : window_t list -> unit

(** Queue up a widget for update.  Probably most useful in callbacks. *)
val queue_draw : widget_t -> unit

(** Event callbacks *)
type event_callback_t
val any_callback :
  ('a -> Gdk.Tags.event_type Gdk.event -> bool) -> 'a -> event_callback_t
val button_callback :
  ('a -> GdkEvent.Button.t -> bool) -> 'a -> event_callback_t
val scroll_callback :
  ('a -> GdkEvent.Scroll.t -> bool) -> 'a -> event_callback_t
val expose_callback :
  ('a -> GdkEvent.Expose.t -> bool) -> 'a -> event_callback_t
val configure_callback :
  ('a -> GdkEvent.Configure.t -> bool) -> 'a -> event_callback_t

(** Box widgets, for housing other widgets *)
val vbox : widget_t list -> widget_t
val hbox : widget_t list -> widget_t

(** Drawing area widget which can be used for custom widgets *)
val drawing_area :
  ?callbacks:(GMisc.drawing_area -> event_callback_t) list ->
  int -> int -> widget_t

(** Slider widget for adjusting a value *)
val slider :
  ?callbacks:(GRange.scale -> unit) list ->
  lower:float -> upper:float -> step:float -> init:float ->
  Gtk.Tags.orientation -> widget_t
