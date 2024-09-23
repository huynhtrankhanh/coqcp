From CoqCP Require Import Options Imperative DisjointSetUnion.
From Generated Require Import DisjointSetUnion.
From stdpp Require Import numbers list.

Definition state : BlockchainState := fun address =>
  if decide (address = repeat (0%Z) 20) then
    BlockchainContract arrayIndex0 _ (arrayType _ environment0) (arrays _ environment0) 100000%Z (funcdef_0__main (fun x => false) (fun x => 0%Z) (fun x => repeat 0%Z 20))
  else ExternallyOwned 0%Z.

Definition stateAfterInteractions arrays : BlockchainState := fun address =>
  if decide (address = repeat (0%Z) 20) then
    BlockchainContract arrayIndex0 _ (arrayType _ environment0) arrays 100000%Z (funcdef_0__main (fun x => false) (fun x => 0%Z) (fun x => repeat 0%Z 20))
  else ExternallyOwned 0%Z.

Fixpoint interact (state : BlockchainState) (interactions : list (Z * Z)) :=
  match interactions with
  | [] => getBalance (state (repeat 1%Z 20))
  | (a, b) :: tail =>
    match invokeContractAux (repeat 1%Z 20) (repeat 0%Z 20) 0%Z state state [a; b] 1 with
    | Some (_, changedState) => interact changedState tail
    | None => 0%Z
    end
  end.

Definition optimalInteractions (x : list (Z * Z)) := forall x', Z.le (interact state x') (interact state x).

Inductive Slot :=
| ReferTo (x : nat)
| Ancestor (x : Tree).

Fixpoint convertToArray (x : list Slot) : list Z :=
  match x with
  | [] => []
  | (ReferTo x) :: tail => (Z.of_nat x) :: convertToArray tail
  | (Ancestor x) :: tail => (Z.sub 256%Z (Z.of_nat (leafCount x))) :: convertToArray tail
  end.

Fixpoint ancestor (dsu : list Slot) (fuel : nat) (index : nat) :=
  match fuel with
  | O => index
  | S fuel => match nth index dsu (Ancestor Unit) with
    | ReferTo x => ancestor dsu fuel x
    | Ancestor _ => index
    end
  end.

Fixpoint pathCompress (dsu : list Slot) (fuel : nat) (index ancestor : nat) :=
  match fuel with
  | O => dsu
  | S fuel => match nth index dsu (Ancestor Unit) with
    | ReferTo x => pathCompress (<[index := ReferTo ancestor]> dsu) fuel x ancestor
    | Ancestor _ => dsu
    end
  end.

Definition performMerge (dsu : list Slot) (tree1 tree2 : Tree) (u v : nat) :=
  <[u := ReferTo v]> (<[v := Ancestor (Unite tree2 tree1)]> dsu).

Definition unite (dsu : list Slot) (a b : nat) :=
  if decide (length dsu <= a) then dsu else
  if decide (length dsu <= b) then dsu else
  let u := ancestor dsu (length dsu) a in
  let dsu1 := pathCompress dsu (length dsu) a u in
  let v := ancestor dsu1 (length dsu1) b in
  let dsu2 := pathCompress dsu1 (length dsu1) b v in
  if decide (u = v) then dsu2 else
  match nth u dsu2 (Ancestor Unit) with
  | ReferTo _ => dsu2
  | Ancestor tree1 => match nth v dsu2 (Ancestor Unit) with
    | ReferTo _ => dsu2
    | Ancestor tree2 =>
      if decide (leafCount tree2 < leafCount tree1) then performMerge dsu tree2 tree1 v u else performMerge dsu tree1 tree2 u v
    end
  end.

Fixpoint dsuFromInteractions (dsu : list Slot) (interactions : list (nat * nat)) :=
  match interactions with
  | [] => dsu
  | (a, b)::tail => dsuFromInteractions (unite dsu a b) tail
  end.

Definition dsuScore (dsu : list Slot) := Z.of_nat (list_sum (map (fun x => match x with | ReferTo _ => 0 | Ancestor x => score x end) dsu)).

Definition dsuLeafCount (dsu : list Slot) := Z.of_nat (list_sum (map (fun x => match x with | ReferTo _ => 0 | Ancestor x => leafCount x end) dsu)).

Definition modelScore (interactions : list (Z * Z)) := dsuScore (dsuFromInteractions (repeat (Ancestor Unit) 100) (map (fun (x : Z * Z) => let (a, b) := x in (Z.to_nat a, Z.to_nat b)) interactions)).

Definition getBalanceInvoke (state : BlockchainState) (communication : list Z) :=
  match invokeContractAux (repeat 1%Z 20) (repeat 0%Z 20) 0 state state communication 1 with
  | Some (a, b) => getBalance (b (repeat 1%Z 20))
  | None => 0%Z
  end.

Lemma invokeCodeNoNone arrays communication : invokeContractAux (repeat 1%Z 20) (repeat 0%Z 20) 0 (stateAfterInteractions arrays) (stateAfterInteractions arrays) communication 1 <> None.
Proof.
Admitted.

Lemma interactEqualsModelScore (x : list (Z * Z)) : interact state x = modelScore x.
Proof.
Admitted.