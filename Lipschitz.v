(* It would be extremely painful to define maps on R by hand all the time.
   So instead we prove a lemma that will allow us to cover most cases. *)

Require Import Setoid Morphisms SetoidClass.

Require Import QArith Qminmax Qabs.
Require Import Cut.
Require Import MiscLemmas.
Require Import Metric.

Class Lip {A B} `{Metric A} `{Metric B} (lipfun : A -> B) :=
{
  modulus : A -> Q -> Q ;
  modulus_nonnegative : forall x q, 0 <= modulus x q ;
  modulus_monotone : forall x q r, 0 <= q -> 0 <= r -> q <= r -> modulus x q <= modulus x r ;
  lipschitz_condition :
    forall (x y : A) q,
      distance x y <= q -> distance (lipfun x) (lipfun y) <= modulus x q * distance x y
}.

Arguments modulus {A} {B} {_} {_} {_} {_} _ {_} _ _.

Instance lip_constant A B `{Metric A} `{Metric B} (y : B) : Lip (const A B y).
Proof.
  refine {| modulus := (fun _ _ => 0) |}.
  - intros ? ; discriminate.
  - intros ? ? ? ? ; discriminate.
  - intros ? ? ? _.
    unfold const ; rewrite distance_diag ; ring_simplify.
    discriminate.
Defined.

Definition idmap {A} : A -> A := fun x => x.

Instance lip_idmap A `{Metric A} : Lip (@idmap A).
Admitted.

Ltac liptac :=
  assumption ||
  match goal with
    | [ |- 0 <= distance _ _ ] => apply distance_nonnegative
    | [ |- 0 <= modulus _ _ _ ] => apply modulus_nonnegative ; liptac
    | [ |- modulus ?f ?x ?q <= modulus ?f ?x ?r ] => apply modulus_monotone ; liptac
    | [ |- 0 <= ?a * ?b ] => apply Qmult_le_0_compat ; liptac
    | [ |- ?a * ?b <= ?c * ?d ] => apply Qmult_le_compat ; liptac
    | [ |- _ ] => idtac
  end.

Instance lip_compose {A B C} `{MA : Metric A} `{MB : Metric B} `{MC : Metric C}
           (g : B -> C) `{@Lip B C _ MB _ MC g}
           (f : A -> B) `{@Lip A B _ MA _ MB f} :
  Lip (g o f).
Proof.
  refine {|
      modulus := fun x q => modulus g (f x) (q * modulus f x q) * modulus f x q
         |}.
  - intros ; liptac.
  - intros ; liptac.
  - intros x y q G.
    unfold compose.
    apply (Qle_trans _ (modulus g (f x) (modulus f x q * distance x y) * distance (f x) (f y))) ;
      [ repeat apply lipschitz_condition; assumption | idtac].
    setoid_rewrite <- Qmult_assoc.
    apply Qmult_le_compat.
    + apply modulus_monotone.
      * liptac.
      * liptac.
        apply (Qle_trans _ (distance x y)) ; [ apply distance_nonnegative | assumption ].
      * rewrite Qmult_comm at 1 ; apply Qmult_le_compat_r ; liptac.
    + apply distance_nonnegative.
    + liptac.
    + apply lipschitz_condition ; assumption.
Defined.

Definition extend (m n : nat) (f : Q^^m -> Q^^n)
           `{@Lip (Q^^m) (Q^^n) _ (PowerMetric m Q) _ (PowerMetric n Q) f} :
  R^^m -> R^^n.
Admitted.

Lemma extend_eq {m n : nat}
      f `{@Lip (Q^^m) (Q^^n) _ (PowerMetric m Q) _ (PowerMetric n Q) f}
      g `{@Lip (Q^^m) (Q^^n) _ (PowerMetric m Q) _ (PowerMetric n Q) g} :
  (forall u v : Q^^m, f u == g u) ->
  (forall x y : R^^m , extend m n f x == extend m n g y).
Admitted.

Lemma extend_compose {k m n : nat} 
      g `{@Lip (Q^^m) (Q^^n) _ (PowerMetric m Q) _ (PowerMetric n Q) g}
      f `{@Lip (Q^^k) (Q^^m) _ (PowerMetric k Q) _ (PowerMetric m Q) f} :
  forall u : R^^k, extend k n (g o f) u == extend m n g (extend k m f u).
Admitted.

Instance lip_fst {A B} `{Metric A} `{Metric B} : Lip (@fst A B).
Proof.
  exists (fun _ _ => 1).
  - intros ; discriminate.
  - intros ; discriminate.
  - intros. admit.
Defined.

Instance lip_snd {A B} `{Metric A} `{Metric B} : Lip (@snd A B).
Admitted.

Definition pairing {A B C} (f : A -> B) (g : A -> C) : A -> B * C :=
  fun x => (f x, g x).

Instance lip_pairing {A B C}
         (f : A -> B) `{Lip A B f}
         (g : A -> C) `{Lip A C g} : Lip (pairing f g).
Admitted.

(* Projecting one of three component. *)
Definition proj_123_1 : Q^^2 -> Q^^0 :=
  fst o fst.

Definition proj_123_2 : Q^^2 -> Q^^0 :=
  snd o fst.

Definition proj_123_3 : Q^^2 -> Q^^0 :=
  snd.

(* Projecting two of three components. *)
Definition proj_123_12 : Q^^2 -> Q^^1 :=
  pairing (fst o fst) (snd o fst).

Definition proj_123_13 : Q^^2 -> Q^^1 :=
  pairing (fst o fst) snd.

Definition proj_123_23 : Q^^2 -> Q^^1 :=
  pairing (snd o fst) snd.

(* The twist map. *)
Definition proj_12_21 : Q^^1 -> Q^^1 :=
  pairing snd fst.

Definition Qplus' : Q^^1 -> Q^^0 := fun u => fst u + snd u.

Instance lip_qplus : Lip Qplus'.
Admitted.

Definition Qmult' : Q^^1 -> Q^^0 := fun u => fst u * snd u.

Instance lip_qmult : Lip Qmult'.
Admitted.

Instance lip_opp : Lip Qopp.
Admitted.
  