module Impl.Graph.Max

open FStar.List

let rec get (i:nat) (l:list int {i < length l}) : int
  = let hd :: tl = l in
    if i = 0 then hd
    else get (i - 1) tl

let rec greater_equal (i:nat) (v:int) (l:list int {length l > 0 && i < length l}) : bool
  = let hd :: tl = l in
    if i = 0 then hd >= v
    else greater_equal (i - 1) v tl

let rec max (l:list int {length l > 0}) : Tot int
  = match l with
  | [x] -> x
  | hd :: tl ->
    let b = max tl in
    if hd > b then hd
    else b

let rec other_max (i:nat) (v:int) (l:list int {length l > 0 && i < length l}) : Tot int (decreases (length l) - i)
  = let hd :: tl = l in
    if length l = 1 then hd
    else if i = 0 then other_max (i + 1) hd l
    else if i = (length l) - 1 then if greater_equal i v l then v else hd
    else if greater_equal i v l then other_max (i + 1) v l
    else other_max (i + 1) hd l

let belongs (l:list int {length l > 0})
  : Lemma (ensures exists (i:nat). i < length l ==> get i l = max l) = ()

let maximum_step (l:list int {length l > 0}) (h:int)
  : Lemma (ensures max (h :: l) >= max l) = ()

let rec rev_maximum (l:list int {length l > 0})
  : Lemma (ensures max ((max l) :: l) == max l)
  = match l with
  | [x] -> ()
  | hd :: tl ->
    rev_maximum tl;
    maximum_step tl hd





let greater_equal_first (v:int) (l:list int {length l > 0}) : bool
  = let hd :: _ = l in
    v >= hd

let max_step (l:list int {length l > 0})
  : Lemma (ensures greater_equal_first (max l) l) = ()

let get_nonempty_tail (l:list int {length l > 0}) : list int
  = match l with
  | [x] -> [x]
  | _ :: tl -> tl

let rec max_strictly_inc (l:list int {length l > 0})
  : Lemma (ensures max l >= max (get_nonempty_tail l))
  = match l with
    | [x] -> ()
    | hd :: tl -> max_strictly_inc tl



let rec maximum (l:list int {length l > 0})
  : Lemma (ensures forall (i:nat). i < length l ==> get i l <= max l)
  = belongs l;
    match l with
    | [x] -> ()
    | hd :: tl ->
      max_strictly_inc tl;
      maximum tl



(*
let rec maximum (l:list int {length l > 0})
  : Lemma (ensures forall (i:nat {i < length l}). max l >= get i l)
  = match l with
  | [x] -> ()
  | hd :: tl ->
    maximum tl;
    max_step tl
*)

(*
let rec other_maximum (l:list int {length l > 0})
  : Lemma (ensures forall (i:nat). i < length l ==> greater_equal i (other_max 0 0 l) l)
  = match l with
  | [x] -> ()
  | _ :: tl -> other_maximum tl
*)

//let rec maximum_step (l:list int {length l > 0})
//  : Lemma (ensures (hd l) <= max (tl l)) = ()

(*
let maximum_main (l:list int {length l > 0})
  : Lemma (ensures forall (i:nat {i < length l}). greater_equal i (max l) l)
  = match l with
  | [x] -> ()
  | _ :: tl -> maximum_helper tl
*)


(*
let rec maximum (l:list int {length l > 0})
  : Lemma (ensures forall (i:nat {i < length l}). greater_equal i (max l) l)
  = match l with
  | [x] -> ()
  | _ :: tl -> maximum tl
*)


(*
let rec max_strictly_inc (l:list int {length l > 0})
  : Lemma (ensures greater_equal_first (max l) l \/ max l >= max (get_tail l))
  = if length l > 1 then match l with
    | hd :: tl -> max_strictly_inc tl
    else ()
*)
