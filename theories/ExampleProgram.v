From CoqCP Require Import Options Imperative.
From stdpp Require Import numbers list strings.
Require Import Coq.Strings.Ascii.
Open Scope type_scope.
Definition environment0 : Environment := {| arrayType := fun name => if decide (name = String "100" (String "105" (String "103" (String "105" (String "116" (EmptyString)))))) then Z else False; arrays := fun name => ltac:(destruct (decide (name = String "100" (String "105" (String "103" (String "105" (String "116" (EmptyString))))))) as [h |]; [(rewrite h; simpl; exact (repeat (0%Z) 1)) |]; exact []) |}.
#[export] Instance arrayTypeEqualityDecidable0 (name : string) : EqDecision (arrayType environment0 name).
Proof. simpl. repeat destruct (decide _). all: solve_decision. Defined.
Definition funcdef_0_PrintDigit_printer (bools : string -> bool) (numbers : string -> Z) : Action (WithArrays (arrayType environment0)) withArraysReturnValue unit := eliminateLocalVariables bools numbers (bind ((bind (let x := bind (Done _ _ _ 0%Z) (fun x => retrieve (arrayType environment0) (String "100" (String "105" (String "103" (String "105" (String "116" (EmptyString)))))) x) in ltac:(simpl in *; exact x)) (fun x => writeChar (arrayType environment0) x))) (fun ignored => Done _ _ _ tt)).
Definition environment1 : Environment := {| arrayType := fun name => if decide (name = String "100" (String "097" (String "116" (String "097" (EmptyString))))) then Z else False; arrays := fun name => ltac:(destruct (decide (name = String "100" (String "097" (String "116" (String "097" (EmptyString)))))) as [h |]; [(rewrite h; simpl; exact (repeat (0%Z) 1)) |]; exact []) |}.
#[export] Instance arrayTypeEqualityDecidable1 (name : string) : EqDecision (arrayType environment1 name).
Proof. simpl. repeat destruct (decide _). all: solve_decision. Defined.
Definition funcdef_0__main (bools : string -> bool) (numbers : string -> Z) : Action (WithArrays (arrayType environment1)) withArraysReturnValue unit := eliminateLocalVariables bools numbers (bind ((bind (Done _ _ _ (fun x => 0%Z)) (fun x => bind (Done _ _ _ (fun x => false)) (fun y => liftToWithLocalVariables (translateArrays (funcdef_0_PrintDigit_printer y x) (arrayType environment1) (fun name => if (decide (name = String "100" (String "105" (String "103" (String "105" (String "116" (EmptyString))))))) then String "100" (String "097" (String "116" (String "097" (EmptyString)))) else "aaaaa") (fun name => ltac:(simpl; repeat case_decide; easy))))))) (fun ignored => Done _ _ _ tt)).
