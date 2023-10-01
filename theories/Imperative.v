From CoqCP Require Import Options.
From stdpp Require Import strings.
Require Import ZArith.
Open Scope Z_scope.

Record Environment := { arrayType: string -> Type; arrays: forall (name : string), list (arrayType name) }.

Record Locals := { numbers: string -> Z; booleans: string -> bool }.

Inductive Action (arrayType : string -> Type) :=
| Done
| Store (arrayName : string) (index : Z) (value : arrayType arrayName) : Action _ -> Action _
| Retrieve (arrayName : string) (index : Z) : (arrayType arrayName -> Action _) -> Action _
| NumberLocalSet (variableName : string) (value : Z) : Action _ ->  Action _
| NumberLocalGet (variableName : string) : (Z -> Action _) -> Action _
| BooleanLocalSet (variableName : string) (value : bool) : Action _ -> Action _
| BooleanLocalGet (variableName : string) : (bool -> Action _) -> Action _
| WriteChar (output : Z) : Action _ -> Action _
| ReadChar : (Z -> Action _) -> Action _
| Flush : Action _ -> Action _.

Fixpoint sameAction {arrayType} (a z : Action arrayType) :=
  match a with
  | Done := z = Done
  | Store a b c act := match z with
    | Store a' b' c' act' := a = a' /\ b = b' /\ c = c' /\ sameAction act act'
    | _ := False
    end.
  | Retrieve a b f := match z with
    | Retrieve a' b' f' := a = a' /\ b = b' /\ (forall x, sameAction (f x) (f' x))
    | _ := False
    end.
  | NumberLocalSet variableName value act := match z with
    | NumberLocalSet variableName' value' act' := variableName = variableName' /\ value = value' /\ sameAction act act'
    | _ := False
    end.
  | NumberLocalGet variableName f := match z with
    | NumberLocalGet variableName' f' := variableName = variableName' /\ (forall x, sameAction (f x) (f' x))
    | _ := False
    end.
  | BooleanLocalSet variableName value act := match z with
    | BooleanLocalSet variableName' value' act' := variableName = variableName' /\ value = value' /\ sameAction act act'
    | _ := False
    end.
  | BooleanLocalGet variableName f := match z with
    | BooleanLocalGet variableName' f' := variableName = variableName' /\ (forall x, sameAction (f x) (f' x))
    | _ := False
    end.
  | WriteChar output act := match z with
    | WriteChar output' act' := output = output' /\ sameAction act act'
    | _ := False
    end.
  | ReadChar f := match z with
    | ReadChar f' := forall x, sameAction (f x) (f' x)
    | _ := False
    end.
  | Flush act := match z with
    | Flush act' := sameAction act act'
    | _ := False
    end.
  end.

Fixpoint join {arrayType} (a z : Action arrayType) :=
  match a with
  | Done _ => z
  | Store _ a b c next => Store _ a b c (join next z)
  | Retrieve _ a b next => Retrieve _ a b (fun x => join (next x) z)
  | NumberLocalSet _ a b next => NumberLocalSet _ a b (join next z)
  | NumberLocalGet _ a next => NumberLocalGet _ a (fun x => join (next x) z)
  | BooleanLocalSet _ a b next => BooleanLocalSet _ a b (join next z)
  | BooleanLocalGet _ a next => BooleanLocalGet _ a (fun x => join (next x) z)
  | WriteChar _ a next => WriteChar _ a (join next z)
  | ReadChar _ next => ReadChar _ (fun x => join (next x) z)
  | Flush _ next => Flush _ (join next z)
  end.

Lemma joinAssoc {arrayType} (x y z :  Action arrayType) : join x (join y z) = join (join x y) z.
Proof.
  induction x as [| a b c next IH | a b next IH | a b next IH | a next IH | a b next IH | a next IH | a next IH | next IH | next IH] in y, z |- *; try easy; simpl; rewrite ?IH; try reflexivity; pose proof (ltac:(intros; apply functional_extensionality; intros; now rewrite IH) : forall b c : Action arrayType, (fun x => join (next x) (join b c)) = (fun x => join (join (next x) b) c)) as ext; now rewrite ext.
Qed.

Fixpoint rangeLoop {arrayType} (n : nat) (f : nat -> Action arrayType) :=
  match n with
  | O => Done arrayType
  | (S n) => join (f n) (rangeLoop n f)
  end.
