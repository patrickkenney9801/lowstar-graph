module Impl.Example.Square

module P = LowStar.Printf
module C = LowStar.Comment
module B = LowStar.Buffer

open FStar.HyperStack.ST
open FStar.Mul
open LowStar.BufferOps

let main (): St Int32.t =
  push_frame ();
  let b: B.buffer UInt32.t = B.alloca 0ul 8ul in
  b.(0ul) <- 255ul;
  C.comment "Calls to printf are desugared via meta-programming";
  let s = "from Low*!" in
  P.(printf "Hello from %s\nbuffer contents: %xul\n"
    s 8ul b done);
  pop_frame ();
  0l

let square (x: UInt32.t): UInt32.t =
  let open FStar.UInt32 in
  x *%^ x
