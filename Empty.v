Require Import List.
Require Import DbLib.Environments.

Require Import Syntax.
Require Import Environment.

(* Predicate for contexts that states their emptyness (DbLib's definition is too limiting) *)
Inductive is_empty {A} : env A -> Prop :=
  | is_empty_nil : is_empty nil
  | is_empty_cons E (EmptyTail : is_empty E) : is_empty (None :: E).

Hint Constructors is_empty : l3.

(* Indirection lemma for use with automation *)
Lemma is_empty_x : forall {A} (e : option A) E,
  e = None -> is_empty E -> is_empty (e :: E).
Proof.
  intros; subst; boom.
Qed.

Hint Resolve is_empty_x : l3.

Example is_empty_ex1 : is_empty (None :: None :: nil : env ty).
Proof. boom. Qed.

Lemma empty_tl : forall {A} (E : env A),
  is_empty E ->
  is_empty (tl E).
Proof.
  intros A E Empty.
  destruct E; auto.
  inversion Empty; subst; auto.
Qed.

Hint Resolve empty_tl : l3.

Lemma empty_lookup : forall {A} x (E : env A),
  is_empty E ->
  lookup x E = None.
Proof.
  intros A x E Empty.
  generalize dependent E.
  induction x as [|x'].
  Case "x = 0".
    intros. inversion Empty; auto.
  Case "x = S x'".
    intros.
    rewrite lookup_successor.
    eboom.
Qed.

Hint Resolve empty_lookup : l3.

Lemma empty_lookup_x : forall {A} x e (E : env A),
  is_empty E ->
  e = lookup x E ->
  e = None.
Proof.
  intros; subst e; auto using empty_lookup.
Qed.

Hint Resolve empty_lookup_x : l3.

Lemma empty_lookup_contra : forall {A} x (E : env A) t,
  is_empty E ->
  lookup x E = Some t ->
  False.
Proof.
  intros A x E t Insert Lookup.
  rewrite empty_lookup in Lookup.
  solve by inversion.
  assumption.
Qed.

Hint Resolve empty_lookup_contra : l3.

Lemma empty_insert_contra : forall {A} x (t : A) E E',
  E = insert x t E' ->
  is_empty E ->
  False.
Proof with eauto.
  intros A x t E E' Eq Empty.
  generalize dependent x.
  generalize dependent t.
  generalize dependent E'.
  induction E as [|e E''].
  Case "E = []".
    eauto using insert_nil.
  Case "E = a :: E".
    intros.
    destruct x as [|x'].
    SCase "x = 0".
      erewrite raw_insert_zero in Eq.
      solve by inversion 2.
    SCase "x = S x'".
      rewrite raw_insert_successor in Eq.
      inversion Eq; subst.
      inversion Empty...
Qed.

Hint Resolve empty_insert_contra : l3.

Lemma empty_insert_injective : forall {A} x1 x2 (t1 : A) t2 E1 E2,
  is_empty E1 ->
  insert x1 t1 E1 = insert x2 t2 E2 ->
  x1 = x2 /\ t1 = t2 /\ is_empty E2.
Proof with (eauto using list_head_eq with l3).
  intros A x1 x2 t1 t2 E1 E2 Empty Insert.
  generalize dependent x2.
  generalize dependent E1.
  generalize dependent E2.
  induction x1 as [|x1'];
    destruct x2 as [|x2'];
    intros;
    try repeat rewrite raw_insert_zero in Insert;
    try repeat rewrite raw_insert_successor in Insert;
    try solve [inversion Insert; subst; eauto using empty_insert_contra];
    try solve [inversion Insert; exfalso; eauto using empty_insert_contra, empty_lookup_contra].
  Case "x1 = S x1', x2 = S x2'".
    assert (x1' = x2' /\ t1 = t2 /\ is_empty (tl E2)) as [XEq [TEq E2Empty]].
      apply IHx1' with (E1 := tl E1)...
      inversion Insert...
    destruct E2 as [|e2 E2']...
    SCase "E2 = e2 :: E2'".
      repeat split...
Qed.