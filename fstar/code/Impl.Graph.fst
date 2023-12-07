module Impl.Graph

open FStar.List
open FStar.Tactics.Typeclasses

let rec get (#a:Type) (i:nat) (l:list a {i < length l}) : a
  = let hd :: tl = l in
    if i = 0 then hd
    else get (i - 1) tl

type node_id = nat
type get_node_id (a:eqtype) (f: (a -> Tot node_id)) =
  (forall a1 a2. (f a1 = f a2) ==> a1 = a2) /\                      (* injective *)
  (forall a1 a2 a3. (f a1 = f a2 /\ f a2 = f a3) ==> f a1 = f a3)   (* transitivity  *)

class graph_edge (#a:eqtype) (v:a) (f: (a -> Tot node_id)) = {
  get_src : get_node_id a f;
  get_dst : get_node_id a f;
}
(*
type get_edge_list (#e:eqtype) (#a:eqtype) (id:node_id) (f: (a -> Tot node_id)) {|graph_edge e f|} (edge_func: (node_id -> list e)) =
  (forall (a1:id). (length (edge_func a1) > 0) ==> get_src (get 0 (edge_func a1)) = a1)

class graph_node (#e:eqtype) (#a:eqtype) (v:a) (f: (a -> Tot node_id)) {|graph_edge e f|} (edge_func: (node_id -> list e)) = {
  id : get_node_id a f;
  get_edges : get_edge_list (id a) f edge_func;
}
*)
(*
let node (i:node_id) (n:Type) = id:i -> value:n
 
type edge (#n:Type) (e:Type) (source destination:node node_id n) =
  | Edge: value:e -> src:source -> dst:destination
 
type graph (#n #e:Type) (ns:list node node_id n) (es: list e) =
  | Graph: nodes:ns -> edges:es

let rec neighbors (n:node a (edge b n)) (neighbor:node a (edge b n)) : bool
 = let value edges = n in
    match edges with
    | [] -> false
    | e :: remaining_edges ->
      let value src dst = e in
      if dst = neighbor then true
      else neighbors (node value remaining_edges) neighbor
     
let rec neighbors_proof (n:node a (edge a n)) (neighbor:node a (edge a n))
  : Lemma (ensures 
      (neighbors n neighbor == (exists (i:nat{i < length n.edges}). (get i n.edges).dst = neighbor))
      /\
      (neighbors n neighbor == (forall (i:nat{i < length n.edges}). (get i n.edges).dst != neighbor))
    ) = ()
*)
