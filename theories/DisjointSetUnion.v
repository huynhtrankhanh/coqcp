From CoqCP Require Import Options ListsEqual.
From stdpp Require Import numbers list.

Inductive Tree :=
| Unit
| Unite (a b : Tree).

Fixpoint encodeToList (x : Tree) : list bool :=
  match x with
  | Unit => [true]
  | Unite a b => encodeToList b ++ encodeToList a ++ [false]
  end.

Fixpoint listToNat (x : list bool) :=
  match x with
  | [] => 0
  | false :: rest => 2 * listToNat rest
  | true :: rest => 2 * listToNat rest + 1
  end.

Definition encodeToNat (x : Tree) := listToNat (encodeToList x).

Lemma encodeToListFirstTrue (x : Tree) : exists s, encodeToList x = true :: s.
Proof.
  induction x as [| a [s1 IHa] b [s2 IHb]].
  - exists []. easy.
  - exists (s2 ++ true :: s1 ++ [false]). simpl. rewrite IHa, IHb. listsEqual.
Qed.

Lemma zeroLtEncodeToNat (x : Tree) : 0 < encodeToNat x.
Proof.
  pose proof encodeToListFirstTrue x as [s h]. unfold encodeToNat. rewrite h. simpl. lia.
Qed.

Lemma listToNatFalse (x : list bool) : listToNat (x ++ [false]) = listToNat x.
Proof.
  induction x as [| head tail IH].
  - simpl. lia.
  - destruct head; simpl; lia.
Qed.

Lemma listToNatTrue (x : list bool) : listToNat (x ++ [true]) > listToNat x + listToNat x.
Proof.
  induction x as [| head tail IH].
  - simpl. lia.
  - destruct head; simpl; lia.
Qed.

Lemma listToNatFalseTrue (x : list bool) : listToNat ((x ++ [false]) ++ [true]) > listToNat x + listToNat x + 1.
Proof.
  induction x as [| head tail IH].
  - simpl. lia.
  - destruct head; simpl; lia.
Qed.

Lemma listToNatAppLt (x a b : list bool) (h : listToNat a < listToNat b) : listToNat (x ++ a) < listToNat (x ++ b).
Proof.
  induction x as [| head tail IH].
  - easy.
  - destruct head; simpl; lia.
Qed.

Lemma listToNatTruePowerOfTwo (x : list bool) : listToNat (x ++ [true]) = listToNat x + 2^(length x).
Proof.
  induction x as [| head tail IH].
  - simpl. lia.
  - destruct head; simpl; lia.
Qed.

Lemma listToNatAppLt' (x a b : list bool) (h : listToNat a < listToNat b) (hLength : length a = length b) : listToNat (a ++ x) < listToNat (b ++ x).
Proof.
  induction x as [| head tail IH] using rev_ind.
  - now rewrite !app_nil_r.
  - destruct head.
    + clear h. rewrite !app_assoc. remember (a ++ tail) as x eqn:hX. remember (b ++ tail) as y eqn:hY.
      assert (hLength2 : length x = length y).
      { subst x. subst y. rewrite !app_length. lia. }
      clear hLength hX hY a b tail. rename IH into h.
      rewrite !listToNatTruePowerOfTwo. rewrite hLength2. lia.
    + rewrite !app_assoc, !listToNatFalse. assumption.
Qed.

Lemma listToNatAppFirst (x a : list bool) : listToNat a <= listToNat (x ++ a).
Proof.
  induction x as [| head tail IH].
  - easy.
  - destruct head; simpl; lia.
Qed.

Lemma encodeToNatSubtermLt1 (a b c : Tree) (h : encodeToNat a < encodeToNat c) : encodeToNat (Unite a b) < encodeToNat (Unite c b).
Proof.
  unfold encodeToNat. simpl. rewrite !app_assoc, !listToNatFalse. apply listToNatAppLt. exact h.
Qed.

Fixpoint leafCount (x : Tree) :=
  match x with
  | Unit => 1
  | Unite a b => leafCount a + leafCount b
  end.

Lemma oneLeqLeafCount (a : Tree) : 1 <= leafCount a.
Proof. induction a as [| a IHa b IHb]; simpl; now (done || lia). Qed.

Lemma leafCountToLengthEncode (a : Tree) : length (encodeToList a) = 2 * leafCount a - 1.
Proof.
  induction a as [| a IHa b IHb].
  - simpl. lia.
  - simpl. rewrite !app_length. simpl. pose proof oneLeqLeafCount a. pose proof oneLeqLeafCount b. lia.
Qed.

Lemma encodeToNatSubtermLt2 (a b c : Tree) (h : encodeToNat a < encodeToNat c) (hLength : leafCount a = leafCount c): encodeToNat (Unite b a) < encodeToNat (Unite b c).
Proof.
  unfold encodeToNat. pose proof leafCountToLengthEncode a. pose proof leafCountToLengthEncode c. simpl. rewrite !app_assoc, !listToNatFalse. apply listToNatAppLt'. { exact h. } lia.
Qed.

Fixpoint score (x : Tree) :=
  match x with
  | Unit => 0
  | Unite a b => leafCount a + leafCount b + score a + score b
  end.

Fixpoint leftUniteCount (x : Tree) :=
  match x with
  | Unite a _ => 1 + leftUniteCount a
  | Unit => 0
  end.

Lemma leftUniteCountLeqLeafCount (x : Tree) : leftUniteCount x <= leafCount x.
Proof.
  induction x as [| a IHa b IHb].
  - simpl. lia.
  - simpl. pose proof oneLeqLeafCount a. pose proof oneLeqLeafCount b. lia.
Qed.

Fixpoint maxLeftUniteCount (x : Tree) :=
  match x with
  | Unite a b => max (leftUniteCount x) (max (maxLeftUniteCount a) (maxLeftUniteCount b))
  | Unit => 0
  end.

Fixpoint totalUniteCount (x : Tree) :=
  match x with
  | Unite a b => 1 + totalUniteCount a + totalUniteCount b
  | Unit => 0
  end.

Lemma leftUniteCountLeqTotalUniteCount (x : Tree) : leftUniteCount x <= totalUniteCount x.
Proof.
  induction x as [| a IHa b IHb].
  - easy.
  - simpl. lia.
Qed.

Lemma totalUniteCountPlusOne (x : Tree) : 1 + totalUniteCount x = leafCount x.
Proof.
  induction x as [| a IHa b IHb].
  - easy.
  - simpl. lia.
Qed.

Lemma rewriteRule1 (a b : Tree) : score (Unite Unit (Unite a b)) = score (Unite (Unite a b) Unit).
Proof. simpl. lia. Qed.

Fixpoint hasRule1 (x : Tree) : bool :=
  match x with
  | Unite Unit (Unite a b) => true
  | Unite a b => orb (hasRule1 a) (hasRule1 b)
  | Unit => false
  end.

Fixpoint replaceRule1 (x : Tree) : Tree :=
  match x with
  | Unite Unit (Unite a b) => Unite (Unite a b) Unit
  | Unite a b => Unite (replaceRule1 a) (replaceRule1 b)
  | Unit => Unit
  end.

Lemma rule1_a (a b : Tree) : leftUniteCount (Unite Unit (Unite a b)) < leftUniteCount (Unite (Unite a b) Unit).
Proof. simpl. lia. Qed.

Lemma rule1_a1 (a b : Tree) : encodeToNat (Unite Unit (Unite a b)) > encodeToNat (Unite (Unite a b) Unit).
Proof.
  unfold encodeToNat.
  simpl. rewrite !listToNatFalse. rewrite app_assoc, !listToNatFalse.
  rewrite (ltac:(listsEqual) : ((encodeToList b ++ encodeToList a) ++ [false]) ++ [true; false] = (((encodeToList b ++ encodeToList a) ++ [false]) ++ [true]) ++ [false]). rewrite !listToNatFalse.
  pose proof listToNatFalseTrue (encodeToList b ++ encodeToList a) as h.
  lia.
Qed.

Lemma rule1_b (a b : Tree) : totalUniteCount (Unite Unit (Unite a b)) = totalUniteCount (Unite (Unite a b) Unit).
Proof. simpl. lia. Qed.

Lemma rule1_c (a b : Tree) : leafCount (Unite Unit (Unite a b)) = leafCount (Unite (Unite a b) Unit).
Proof. simpl. lia. Qed.

Lemma rewriteRule2 (a b c d : Tree) (h : leafCount a >= leafCount d) : score (Unite (Unite a b) (Unite c d)) <= score (Unite (Unite (Unite a b) c) d).
Proof. simpl. lia. Qed.

Lemma rule2_a (a b c d : Tree) : leftUniteCount (Unite (Unite a b) (Unite c d)) < leftUniteCount (Unite (Unite (Unite a b) c) d).
Proof. simpl. lia. Qed.

Lemma rule2_a1 (a b c d : Tree) : encodeToNat (Unite (Unite a b) (Unite c d)) > encodeToNat (Unite (Unite (Unite a b) c) d).
Proof.
  unfold encodeToNat. simpl. rewrite !app_assoc, !listToNatFalse, <- !app_assoc. apply listToNatAppLt. apply listToNatAppLt. simpl.
  assert (h : 0 < listToNat (encodeToList b ++ encodeToList a)).
  { pose proof encodeToListFirstTrue b as [s1 h1].
    pose proof encodeToListFirstTrue a as [s2 h2].
    rewrite h1, h2. simpl. pose proof listToNatAppFirst s1 (true :: s2).
    pose proof (ltac:(simpl; lia) : 0 < listToNat (true :: s2)).
    lia. } lia.
Qed.

Lemma rule2_b (a b c d : Tree) : totalUniteCount (Unite (Unite a b) (Unite c d)) = totalUniteCount (Unite (Unite (Unite a b) c) d).
Proof. simpl. lia. Qed.

Lemma rule2_c (a b c d : Tree) : leafCount (Unite (Unite a b) (Unite c d)) = leafCount (Unite (Unite (Unite a b) c) d).
Proof. simpl. lia. Qed.

Lemma rewriteRule3 (a b c d : Tree) (h : leafCount a < leafCount d) : score (Unite (Unite a b) (Unite c d)) < score (Unite (Unite (Unite d c) b) a).
Proof. simpl. lia. Qed.

Lemma rule3_b (a b c d : Tree) : totalUniteCount (Unite (Unite a b) (Unite c d)) = totalUniteCount (Unite (Unite (Unite d c) b) a).
Proof. simpl. lia. Qed.

Lemma rule3_c (a b c d : Tree) : leafCount (Unite (Unite a b) (Unite c d)) = leafCount (Unite (Unite (Unite d c) b) a).
Proof. simpl. lia. Qed.

Lemma scoreUpperBound (x : Tree) : score x <= (leafCount x) * (leafCount x).
Proof.
  induction x as [| a IHa b IHb].
  - simpl. lia.
  - simpl. pose proof oneLeqLeafCount a. pose proof oneLeqLeafCount b.
    assert (h : forall a b, 1 <= a -> 1 <= b -> a * a + b * b + a + b <= (a + b) * (a + b)).
    { intros x y hx hy. rewrite (ltac:(lia) : (x + y) * (x + y) = x * x + 2 * x * y + y * y).
      pose proof (ltac:(intros; lia) : x + y <= 2 * x * y -> x * x + y * y + x + y <= x * x + 2 * x * y + y * y) as hi.
      apply hi. clear hi. zify.
      pose proof (ltac:(intros; lia) : ((Z.of_nat x * Z.of_nat y - Z.of_nat x) + (Z.of_nat x * Z.of_nat y - Z.of_nat y) >= 0)%Z -> (Z.of_nat x + Z.of_nat y ≤ 2 * Z.of_nat x * Z.of_nat y)%Z) as hi. apply hi. clear hi.
      pose proof (ltac:(intros; lia) : forall (a b : Z), (a * b - b = (a - 1) * b)%Z) as hi. rewrite hi. clear hi.
      pose proof (ltac:(intros; lia) : forall (a b : Z), (a * b - a = (b - 1) * a)%Z) as hi. rewrite hi. clear hi.
      pose proof (ltac:(intros; lia) : forall (a b : Z), (0 <= a)%Z -> (0 <= b)%Z -> (0 <= a * b)%Z) as h.
      pose proof h ((Z.of_nat y - 1)%Z) (Z.of_nat x) ltac:(lia) ltac:(lia).
      pose proof h ((Z.of_nat x - 1)%Z) (Z.of_nat y) ltac:(lia) ltac:(lia).
      lia. }
    pose proof h (leafCount a) (leafCount b) ltac:(assumption) ltac:(assumption). lia.
Qed.

Fixpoint constructTree (n : nat) : Tree :=
  match n with
  | O => Unit
  | S n => Unite (constructTree n) Unit
  end.

Lemma constructTreeSize (n : nat) : leafCount (constructTree n) = S n.
Proof.
  induction n as [| n IH].
  - easy.
  - simpl. lia.
Qed.

Fixpoint generateProduct {A B : Type} (a : list A) (b : list B) : list (A * B) :=
  match a with
  | [] => []
  | head :: tail => map (fun x => (head, x)) b ++ generateProduct tail b
  end.

Lemma inProductList {A B : Type} (a : list A) (b : list B) (elementA : A) (hA : In elementA a) (elementB : B) (hB : In elementB b) : In (elementA, elementB) (generateProduct a b).
Proof.
  induction a as [| head tail IH].
  - simpl in hA. exfalso. exact hA.
  - destruct hA as [hL | hR].
    + subst head. simpl. apply in_or_app. left. clear IH.
      induction b as [| head1 tail1 IH1]; [(simpl in hB); exfalso; exact hB |]. simpl. destruct hB as [h1 | h2]. { left. rewrite h1. trivial. } right. exact (IH1 h2).
    + simpl. apply in_or_app. right. exact (IH hR).
Qed.

Lemma inProductList2 {A B : Type} (a : list A) (b : list B) (elementA : A) (elementB : B) (h : In (elementA, elementB) (generateProduct a b)) : In elementA a /\ In elementB b.
Proof.
  induction a as [| head tail IH].
  - simpl in h. exfalso. exact h.
  - simpl in h. rewrite in_app_iff in h. destruct h as [h | h].
    + clear IH. induction b as [| head1 tail1 IH1]. { simpl in h. exfalso. exact h. } simpl in h. destruct h as [h | h]. { rewrite pair_eq in h. destruct h as [hA hB]. subst head. subst head1. split; simpl; left; trivial. } pose proof IH1 h as [hA hB]. split. { assumption. } simpl. right. assumption.
    + pose proof IH h as [hA hB]. split. { simpl. right. assumption. } assumption.
Qed.

Lemma enumerateTrees (n : nat) : { x : list Tree | forall tree : Tree, leafCount tree = n <-> In tree x }.
Proof.
  induction (lt_wf n) as [n _ IH].
  - destruct (decide (n = 0)) as [h | h].
    + apply (exist _ []). subst n. intros tree. pose proof oneLeqLeafCount tree. simpl. split; lia.
    + destruct (decide (n = 1)) as [h1 | h1].
      * subst n. apply (exist _ [Unit]). intros tree.
        destruct tree as [| tree1 tree2]. { simpl. intuition tauto. }
        simpl. pose proof oneLeqLeafCount tree1. pose proof oneLeqLeafCount tree2. split. { lia. } intro h1. destruct h1 as [h1 | h1]. { pose proof (ltac:(easy) : Unit <> Unite tree1 tree2) h1. exfalso. assumption. } exfalso. assumption.
      * assert (h2 : forall (leftSize : nat) (hLeft : leftSize < n) (hLeft2 : 0 < leftSize), {x : list Tree | forall tree : Tree, (match tree with | Unit => False | Unite a b => leafCount a <= leftSize /\ leafCount b = n - leafCount a end) <-> In tree x}).
        { intros left hLeft hLeft2.
          induction left as [| left IH2]; [lia |].
          pose proof IH (S left) ltac:(lia) as [a ha].
          pose proof IH (n - S left) ltac:(lia) as [b hb].
          destruct (decide (left = 0)) as [h2 | h2].
          - apply (exist _ (map (fun (x : Tree * Tree) => let (a, b) := x in Unite a b) (generateProduct a b))).
            intros [| a1 b1]. { split; intro hTree. { exfalso. exact hTree. } remember (generateProduct a b) as l eqn:hl. induction l as [| head tail IH3] in hTree |-. { simpl in hTree. exact hTree. } destruct hTree as [hTree | hTree]. { destruct head as [aa bb]. exact ((ltac:(easy) : Unite aa bb <> Unit) hTree). } tauto. }
            pose proof oneLeqLeafCount a1. rewrite (ltac:(lia) : leafCount a1 <= S left <-> leafCount a1 = S left).
            split.
            { intros [hTree1 hTree2].
              pose proof in_map (fun (x : Tree * Tree) => let (a, b) := x in Unite a b) (generateProduct a b) (a1, b1) as step. simpl in step. apply step. apply inProductList. { rewrite <- ha. assumption. } rewrite <- hb. lia. }
            { rewrite in_map_iff. intros [[aa bb] [h4 h3]].
              pose proof inProductList2 a b aa bb h3 as [hIn1 hIn2]. rewrite <- ha in hIn1. injection h4. intros hbb haa. subst aa bb. split. { exact hIn1. } pose proof hb b1 as hb1. rewrite hIn1, hb1. assumption. }
          - pose proof IH2 ltac:(lia) ltac:(lia) as [previous hPrevious]. apply (exist _ (map (fun (x : Tree * Tree) => let (a, b) := x in Unite a b) (generateProduct a b) ++ previous)). intros [| aa bb].
            + split. { tauto. } intro h3. pose proof in_app_or _ _ _ h3 as [H | H].
              * remember (generateProduct a b) as l eqn:hl. induction l as [| head tail IH3] in H |-. { simpl in H. exact H. }
                destruct H as [H | H]. { destruct head as [aa bb]. exact ((ltac:(easy) : Unite aa bb <> Unit) H). } exact (IH3 H).
              * pose proof hPrevious Unit as [_ step]. exact (step H).
            + split.
              * intros [haa hbb]. apply in_or_app.
                pose proof (ltac:(lia) : leafCount aa <= left \/ leafCount aa = S left) as [hIf | hIf].
                { right. rewrite <- (hPrevious (Unite aa bb)). simpl. lia. }
                left. rewrite in_map_iff. exists (aa, bb). split. { trivial. } apply inProductList. { rewrite <- ha. lia. } { rewrite <- hb. lia. }
              * intro hmap. pose proof in_app_or _ _ _ hmap as [H | H].
                { rewrite in_map_iff in H. destruct H as [[a1 b1] [hinj hin]]. injection hinj. intros hbb haa. subst bb aa. pose proof inProductList2 _ _ _ _ hin as [hina hinb]. rewrite <- ha in hina. split. { lia. } rewrite hina. rewrite hb. exact hinb. }
                pose proof hPrevious (Unite aa bb) as step. simpl in step. rewrite <- step in H. lia. }
          pose proof h2 (n - 1) ltac:(lia) ltac:(lia) as [l hl].
          apply (exist _ l).
          destruct tree as [| a b].
          { split. { simpl. intro. lia. } pose proof hl Unit as step. simpl in step. rewrite <- step. easy. }
          rewrite <- (hl (Unite a b)). simpl. pose proof oneLeqLeafCount b. lia.
Defined.

Definition optimalTree (x : Tree) := forall y, leafCount x = leafCount y -> score y <= score x.

Fixpoint bestTree (l : list Tree) (currentBest : Tree) :=
  match l with
  | [] => currentBest
  | head :: tail =>
    if decide (score currentBest < score head) then
      bestTree tail head
    else bestTree tail currentBest
  end.

Lemma currentBestLeqBestTree (l : list Tree) (currentBest : Tree) : score currentBest <= score (bestTree l currentBest).
Proof.
  induction l as [| head tail IH] in currentBest |- *.
  - simpl. lia.
  - simpl. case_decide. { pose proof IH head. lia. } apply IH.
Qed.

Lemma differentCurrentBest (l : list Tree) (currentBest currentBest1 : Tree) (hLeq : score currentBest <= score currentBest1) : score (bestTree l currentBest) <= score (bestTree l currentBest1).
Proof.
  induction l as [| head tail IH] in currentBest, hLeq |- *. { simpl. lia. }
  simpl. pose proof IH currentBest. pose proof IH head. repeat case_decide; lia.
Qed.

Lemma bestTreeIsBest (l : list Tree) (x : Tree) (hIn : In x l) (arbitrary : Tree) (hIn2 : In arbitrary l) : score arbitrary <= score (bestTree l x).
Proof.
  induction l as [| head tail IH].
  - simpl in hIn. exfalso. exact hIn.
  - destruct hIn as [hIn | hIn]. { subst x. destruct hIn2 as [hIn2 | hIn2]. { subst head. simpl. case_decide; apply currentBestLeqBestTree. } clear IH. induction tail as [| hh ta IH]. { simpl in hIn2. lia. } simpl. case_decide; try lia. simpl in IH. case_decide; try lia. case_decide. 
    - destruct hIn2 as [h | h]. { subst hh. apply currentBestLeqBestTree. } pose proof IH h. pose proof differentCurrentBest ta head hh ltac:(lia). lia.
    - destruct hIn2 as [h | h]. { subst hh. pose proof currentBestLeqBestTree ta arbitrary. pose proof differentCurrentBest ta arbitrary head ltac:(lia). lia. } exact (IH h). }
    destruct hIn2 as [hIn2 | hIn2]. { subst arbitrary. simpl. case_decide; pose proof currentBestLeqBestTree tail head. { lia. } pose proof differentCurrentBest tail head x. lia. }
    pose proof IH hIn hIn2. simpl. case_decide; try lia. pose proof differentCurrentBest tail x head ltac:(lia). lia.
Qed.

Lemma bestTreeInList (l : list Tree) (x : Tree) : In (bestTree l x) l \/ bestTree l x = x.
Proof.
  induction l as [| head tail IH] in x |- *.
  - simpl. right. trivial.
  - simpl. case_decide.
    + pose proof IH head as [a | b]. { left. right. exact a. } { left. left. symmetry. exact b. }
    + pose proof IH x as [a | b]. { left. right. exact a. } { right. exact b. }
Qed.

Lemma bestTreeInList2 (l : list Tree) (x : Tree) (hX : In x l) : In (bestTree l x) l.
Proof.
  pose proof bestTreeInList l x as [a | a].
  - assumption.
  - rewrite a. assumption.
Qed.

Lemma getOptimalTree (n : nat) : { x : Tree | optimalTree x /\ leafCount x = S n }.
Proof.
  pose proof enumerateTrees (S n) as [l spec].
  pose proof spec (constructTree n) as [h _].
  pose proof h (constructTreeSize n) as h1.
  pose proof bestTreeIsBest l _ h1 as H.
  apply (exist _ (bestTree l (constructTree n))).
  split.
  - intros arbitrary h2. pose proof H arbitrary as step. rewrite <- spec in step. rewrite <- h2 in step. pose proof (bestTreeInList2 l (constructTree n) h1) as g. rewrite <- spec in g. exact (step g).
  - pose proof (bestTreeInList2 l (constructTree n) h1) as g. rewrite <- spec in g. exact g.
Defined.
