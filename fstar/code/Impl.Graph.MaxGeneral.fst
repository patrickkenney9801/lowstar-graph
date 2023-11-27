module Impl.Graph.MaxGeneral

open FStar.List
open FStar.Tactics.Typeclasses
open FStar.Order
open FStar.OrdSet
module U64 = FStar.UInt64

let rec get (#a:Type) (i:nat) (l:list a {i < length l}) : a
  = let hd :: tl = l in
    if i = 0 then hd
    else get (i - 1) tl

let get_nonempty_tail (#a:Type) (l:list a {length l > 0}) : list a
  = match l with
  | [x] -> [x]
  | _ :: tl -> tl

let rec max (#a:eqtype) (f:cmp a) (l:list a {length l > 0}) : Tot a
  = match l with
  | [x] -> x
  | hd :: tl ->
    let b = max f tl in
    if f hd b then hd
    else b

let belongs (#a:eqtype) (f:cmp a) (l:list a {length l > 0})
  : Lemma (ensures
      (exists (i:nat). i < length l ==> get i l == max f l) /\
      ((length l = 1) ==> get 0 l == max f l)
    ) = ()

let max_step (#a:eqtype) (f:cmp a) (l:list a {length l > 0})
  : Lemma (ensures f (max f l) (get 0 l)) = ()

let rec max_strictly_inc (#a:eqtype) (f:cmp a) (l:list a {length l > 0})
  : Lemma (ensures f (max f l) (max f (get_nonempty_tail l)))
  = match l with
    | [x] -> ()
    | hd :: tl -> max_strictly_inc f tl

let rec maximum (#a:eqtype) (f:cmp a) (l:list a {length l > 0})
  : Lemma (ensures forall (i:nat). i < length l ==> f (max f l) (get i l))
  = belongs f l;
    match l with
    | [x] -> ()
    | hd :: tl ->
      max_strictly_inc f tl;
      maximum f tl

let u64_cmp (x y:U64.t) : Tot bool
  = U64.gte x y

let max_uint64 (l:list U64.t {length l > 0}) : Tot U64.t
  = max u64_cmp l
