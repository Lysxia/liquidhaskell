{-@ LIQUID "--higherorder"     @-}
{-@ LIQUID "--totality"        @-}
{-@ LIQUID "--automatic-instances=liquidinstances" @-}

module Fibonacci where
import Language.Haskell.Liquid.ProofCombinators


-- | Proves that the fibonacci function is increasing


-- | Definition of the function in Haskell 
-- | the annotation axiomatize means that 
-- | in the logic, the body of increase is known
-- | (each time the function fib is applied, 
-- | there is an unfold in the logic)

{-@ fib :: n:Nat -> Nat @-}
{-@ axiomatize fib @-}

fib :: Int -> Int
fib n
  | n == 0    = 0
  | n == 1    = 1
  | otherwise = fib (n-1) + fib (n-2)

-- | How to encode proofs:
-- | ==., <=., and <. stand for the logical ==, <=, < resp.
-- | If the proofs do not derive automatically, user can 
-- | optionally provide the Proofean statements, after `?`
-- | Note, no inference occurs: logic only reasons about
-- | linear arithmetic and equalities

lemma_fib :: Int -> Proof
{-@ lemma_fib :: x:{Nat | 1 < x } -> { 0 < fib x } @-}
lemma_fib x 
  | x == 2
  = trivial 
  | 2 < x 
  = lemma_fib (x-1) &&& fibNat (x-2)

{-@ fibNat :: i:Nat -> {0 <= fib i } @-} 
fibNat :: Int -> Proof 
fibNat 0 = trivial
fibNat 1 = trivial
fibNat i = fibNat (i-1) &&& fibNat (i-2)

{-@ fib_increasing :: x:Nat -> y:{Nat | x < y} -> { fib x <= fib y } / [x, y] @-} 
fib_increasing :: Int -> Int -> Proof 
fib_increasing x y 
  | x == 0, y == 1
  = trivial
  | x == 0 
  = lemma_fib y
  | x == 1, y == 2
  = trivial                  
  | x == 1, 2 < y
  = fib_increasing 1 (y-1) &&& fibNat (y-2)
  | otherwise
  = fib_increasing (x-2) (y-2) &&& fib_increasing (x-1) (y-1) &&& fibNat (x-2) &&& fibNat (y-2)
