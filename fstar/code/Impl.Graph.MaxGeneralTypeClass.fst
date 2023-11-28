module Impl.Graph.MaxGeneralTypeClass

open FStar.List
open FStar.Tactics.Typeclasses
module O = FStar.Order
open FStar.Class.TotalOrder.Raw
module U64 = FStar.UInt64

// WARNING: UNPROVEN since x < y =!=> y < x given (#a:Type) {|totalorder a|} (x y:a)

instance _ : totalorder nat = {
  compare = Order.compare_int;
}

let add_one (i:int) : int = i + 1
let add_one_pf (i:int) : Lemma (ensures add_one i = i + 1) = ()
let rec get (#a:Type) (i:nat) (l:list a {i < length l}) : a
  = let hd :: tl = l in if i = 0 then hd else get (i - 1) tl
let rec get_counter (#a:Type) (i:nat) (desired:nat {i <= desired}) (l:list a {desired - i < length l}) : Tot a (decreases (desired - i))
  = let hd :: tl = l in if i = desired then hd else get_counter (i + 1) desired tl

(*
let rec get (#a:Type) (i:nat) (l:list a {i < length l}) : a
  = let hd :: tl = l in
    if i = 0 then hd
    else get (i - 1) tl
*)
let get_nonempty_tail (#a:Type) (l:list a {length l > 0}) : list a
  = match l with
  | [x] -> [x]
  | _ :: tl -> tl

let rec max (#a:Type) {|totalorder a|} (l:list a {length l > 0}) : Tot a
  = match l with
  | [x] -> x
  | hd :: tl ->
    let b = max tl in
    if hd > b then hd
    else b

let belongs (#a:Type) {|totalorder a|} (l:list a {length l > 0})
  : Lemma (ensures
      (exists (i:nat). i < length l ==> get i l == max l) /\
      ((length l = 1) ==> get 0 l == max l)
    ) = ()

(*
let rec max_greater (#a:Type) {|totalorder a|} (l:list a {length l > 0})
  : Lemma (ensures (max l == get 0 l) \/ (max l > get 0 l))
  = match l with
    | [x] -> belongs l
    | hd :: tl ->
      assert (max l > max tl \/ max l == max tl);
      assert (max l > hd \/ max l == hd);
      max_greater tl

let rec max_greater (#a:Type) {|totalorder a|} (l:list a {length l > 0})
  : Lemma (ensures (max l == get 0 l) \/ (max l > get 0 l))
  = match l with
    | [x] -> belongs l
    | hd :: tl ->
      assert (max l > max tl \/ max l == max tl);
      assert (max l > hd \/ max l == hd);
      max_greater tl
*)



(*
let rec max_strictly_inc (#a:Type) {|totalorder a|} (l:list a {length l > 0})
  : Lemma (
      ensures (
        ((max l > max (get_nonempty_tail l)) \/ (max l == max (get_nonempty_tail l))) /\
        (get 0 l > max l ==> max l > max (get_nonempty_tail l)) /\
        (((length l = 1) ==> get 0 l == max l))
      )
    )
  = match l with
    | [x] -> ()
    | hd :: tl ->
      max_strictly_inc tl

let order_facts (o:order)
  : Lemma (
      ensures (
        (lt o <==> (o =!= Gt /\ o =!= Eq)) /\
        (gt o <==> (o =!= Lt /\ o =!= Eq)) /\
        (eq o <==> (o =!= Lt /\ o =!= Gt)) /\
        (le o <==> (o == Lt \/ o == Eq)) /\
        (ge o <==> (o == Gt \/ o == Eq)) /\
        (lt o ==> (o =!= Eq))
      )
    ) = ()

let facts (#a:Type) {|totalorder a|} (x y:a)
  : Lemma (
      ensures (
        (x < y ==> x < y) /\
        (x > y ==> x > y) /\
        (x < y ==> x <= y) /\
        (x > y ==> x >= y) /\
        (x == y ==> y == x) /\
        (x =!= y ==> y =!= x) /\
        (x >= y ==> not (x < y)) /\
        (x <= y ==> not (x > y)) /\
        (x > y ==> not (x <= y)) /\
        (x < y ==> not (x >= y)) /\
        (x < y ==> (compare x y =!= Eq)) /\
        (x < y ==> (compare x y =!= Gt)) /\
        (x < y <==> (compare x y =!= Eq /\ (compare x y =!= Gt))) /\
        (x < y ==> (compare y x =!= Eq))
        //(x < y <==> (compare y x =!= Eq /\ (compare y x =!= Lt)))
        //(x >= y ==> (x > y \/ x == y))
      )
    ) = ()


let rec small_fact (#a:Type) {|totalorder a|} (l:list a {length l > 0})
  : Lemma (
      ensures (
        //(max l > get 0 l ==> length l > 1) /\
        //(length l = 1 ==> max l == get 0 l) /\
        (max l > get 0 l ==> max l == max (get_nonempty_tail l))
      )
    )
  = match l with
    | [x] -> assert (max l == x)
    | hd :: tl ->
      assert (max tl > hd ==> max tl > hd);
      assert (max tl >= hd ==> not (max tl < hd));
      assert (max tl <= hd ==> not (max tl > hd));
      assert (max tl >= hd ==> (max tl > hd \/ max tl == hd));
      assert (max tl > hd ==> (hd <= max tl));
      assert (hd > max tl ==> hd == max l);
      assert (hd > max tl ==> max tl < hd);
      assert (max tl > hd ==> (hd < max tl));
      assert (hd > max tl ==> max l > max tl);
      assert (hd > max tl ==> max l == hd);
      assert (hd < max tl ==> max l =!= hd);
      assert (hd < max tl ==> max l == max tl);
      assert (max l == hd ==> max l >= max tl);
      assert (max l >= hd ==> (max l > hd \/ max l == hd));
      assert (max l > hd ==> (hd < max l \/ max l == hd));
      assert (max l > hd ==> (hd < max l));

      assert (max l > hd ==> max l == max tl);

//      assert (max l > get 0 l ==> max l == max tl);
      assert (max tl > get 0 l ==> get 0 l <= max tl);
      assert (get 0 l > max tl ==> get 0 l == max l);
//      assert (get 0 l > max tl ==> max tl < get 0 l);



      max_strictly_inc tl;
      small_fact tl





let rec smaller_elts_irrelevant (#a:Type) {|totalorder a|} (l:list a {length l > 0})
  : Lemma (
      ensures (
        (max l > get 0 l ==> (length l > 1 /\ max l == max (get_nonempty_tail l)))
      )
    )
  = match l with
    | [x] -> ()
    | hd :: tl ->
      max_strictly_inc tl;
      assert (max l > get 0 l ==> max l == max tl);
      assert (max l > hd ==> max l == max tl);
      assert (hd < max l ==> max l == max tl);
      smaller_elts_irrelevant tl

let rec max_step (#a:Type) {|totalorder a|} (l:list a {length l > 0})
  : Lemma (ensures (
      (max l > get 0 l) \/ (max l == get 0 l))
    )
  = match l with
    | [x] -> assert (max l == x)
    | hd :: tl ->
      assert (max l > max tl \/ max l == max tl);
      assert (hd > max l ==> max l > max tl);
      //assert (hd <= max l ==> max l == max tl);
      //assert (max l > hd \/ max l == hd);
      //assert (max l > get 0 l \/ max l == get 0 l);
      max_strictly_inc tl;
      max_step tl
*)
(*
let rec maximum (#a:Type) {|totalorder a|} (l:list a {length l > 0})
  : Lemma (
      ensures (
        forall (i:nat). i < length l ==> ((max l == get i l) \/ (max l > get i l))
      )
  )
  = belongs l;
    match l with
    | [x] -> assert (max l == x \/ max l > x)
    | hd :: tl ->
      assert (max l > max tl \/ max l == max tl);
      assert (max l > hd \/ max l == hd);
      assert (max l > get 0 l \/ max l == get 0 l);
      assert (max l > get ((length l) - 1) l \/ max l == get ((length l) - 1) l);
      max_strictly_inc tl;
      maximum tl
*)


let max_nat (l:list nat {length l > 0}) : Tot nat
  = max l

let u64_cmp (x y:U64.t) : O.order
  = if U64.gt x y then O.Gt
    else if U64.lt x y then O.Lt
    else O.Eq

instance _ : totalorder U64.t = {
  compare = u64_cmp;
}

let max_u64 (l:list U64.t {length l > 0}) : Tot U64.t
  = max l
