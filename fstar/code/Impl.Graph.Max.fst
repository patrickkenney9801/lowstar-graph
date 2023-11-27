module Impl.Graph.Max

open FStar.List

let rec get (i:nat) (l:list int {i < length l}) : int
  = let hd :: tl = l in
    if i = 0 then hd
    else get (i - 1) tl

let get_nonempty_tail (l:list int {length l > 0}) : list int
  = match l with
  | [x] -> [x]
  | _ :: tl -> tl

let rec max (l:list int {length l > 0}) : Tot int
  = match l with
  | [x] -> x
  | hd :: tl ->
    let b = max tl in
    if hd > b then hd
    else b

let belongs (l:list int {length l > 0})
  : Lemma (ensures exists (i:nat). i < length l ==> get i l = max l) = ()

let max_step (l:list int {length l > 0})
  : Lemma (ensures get 0 l <= (max l)) = ()

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
