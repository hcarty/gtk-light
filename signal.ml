open React

type 'a t = {
  signal : 'a signal;
  setter : ('a -> unit);
}

let init x =
  let signal, setter = S.create x in
  { signal = signal; setter = setter }

let get s = S.value s.signal

let set s x = s.setter x

let trace f s = { s with signal = S.trace f s.signal }
