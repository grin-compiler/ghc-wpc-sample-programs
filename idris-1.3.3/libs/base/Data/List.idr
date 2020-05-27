module Data.List

%access public export

||| A proof that some element is found in a list.
|||
||| Example: `the (Elem "bar" ["foo", "bar", "baz"]) (tactics { search })`
data Elem : a -> List a -> Type where
     ||| A proof that the element is at the front of the list.
     |||
     ||| Example: `the (Elem "a" ["a", "b"]) Here`
     Here : Elem x (x :: xs)
     ||| A proof that the element is after the front of the list
     |||
     ||| Example: `the (Elem "b" ["a", "b"]) (There Here)`
     There : (later : Elem x xs) -> Elem x (y :: xs)

||| `Here` will never equal `There`.
hereIsNotThere : Not (Here = There _)
hereIsNotThere Refl impossible

||| If the tails don't match, neither will references to them.
tailMismatch : Not (this = that) -> Not (There this = There that)
tailMismatch f Refl = f Refl

implementation DecEq (Elem x xs) where
  decEq Here Here = Yes Refl
  decEq Here (There later) = No hereIsNotThere
  decEq (There later) Here = No (hereIsNotThere . sym)
  decEq (There this) (There that) with (decEq this that)
    decEq (There this) (There this) | Yes Refl  = Yes Refl
    decEq (There this) (There that) | No contra = No (tailMismatch contra)

implementation Uninhabited (Elem {a} x []) where
     uninhabited Here impossible
     uninhabited (There p) impossible

||| An item not in the head and not in the tail is not in the List at all
neitherHereNorThere : {x, y : a} -> {xs : List a} -> Not (x = y) -> Not (Elem x xs) -> Not (Elem x (y :: xs))
neitherHereNorThere xneqy xninxs Here = xneqy Refl
neitherHereNorThere xneqy xninxs (There xinxs) = xninxs xinxs

||| Is the given element a member of the given list.
|||
||| @x The element to be tested.
||| @xs The list to be checked against
isElem : DecEq a => (x : a) -> (xs : List a) -> Dec (Elem x xs)
isElem x [] = No absurd
isElem x (y :: xs) with (decEq x y)
  isElem x (x :: xs) | (Yes Refl) = Yes Here
  isElem x (y :: xs) | (No xneqy) with (isElem x xs)
    isElem x (y :: xs) | (No xneqy) | (Yes xinxs) = Yes (There xinxs)
    isElem x (y :: xs) | (No xneqy) | (No xninxs) = No (neitherHereNorThere xneqy xninxs)

||| Remove the element at the given position.
|||
||| @xs The list to be removed from
||| @p A proof that the element to be removed is in the list
dropElem : (xs : List a) -> (p : Elem x xs) -> List a
dropElem (x :: ys) Here = ys
dropElem (x :: ys) (There p) = x :: dropElem ys p

||| The intersectBy function returns the intersect of two lists by user-supplied equality predicate.
intersectBy : (a -> a -> Bool) -> List a -> List a -> List a
intersectBy eq xs ys = [x | x <- xs, any (eq x) ys]

||| Compute the intersection of two lists according to their `Eq` implementation.
|||
||| ```idris example
||| intersect [1, 2, 3, 4] [2, 4, 6, 8]
||| ```
|||
intersect : (Eq a) => List a -> List a -> List a
intersect = intersectBy (==)
