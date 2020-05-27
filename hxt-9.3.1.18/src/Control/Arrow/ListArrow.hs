-- ------------------------------------------------------------

{- |
   Module     : Control.Arrow.ListArrow
   Copyright  : Copyright (C) 2005 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe\@fh-wedel.de)
   Stability  : experimental
   Portability: portable

   Implementation of pure list arrows

-}

-- ------------------------------------------------------------

module Control.Arrow.ListArrow
    ( LA(..)
    , fromLA
    )
where

import           Prelude hiding (id, (.))

import           Control.Category

import           Control.Arrow
import           Control.Arrow.ArrowIf
import           Control.Arrow.ArrowList
import           Control.Arrow.ArrowNF
import           Control.Arrow.ArrowTree
import           Control.Arrow.ArrowNavigatableTree

import           Control.DeepSeq

import           Data.List ( partition )

-- ------------------------------------------------------------

-- | pure list arrow data type

newtype LA a b = LA { runLA :: a -> [b] }

instance Category LA where
    id                  = LA $ (:[])
    {-# INLINE id #-}
    LA g . LA f         = LA $ concatMap g . f
    {-# INLINE (.) #-}

instance Arrow LA where
    arr f               = LA $ \ x -> [f x]
    {-# INLINE arr #-}
    first (LA f)        = LA $ \ ~(x1, x2) -> [ (y1, x2) | y1 <- f x1 ]

    -- just for efficiency

    second (LA g)       = LA $ \ ~(x1, x2) -> [ (x1, y2) | y2 <- g x2 ]
    LA f *** LA g       = LA $ \ ~(x1, x2) -> [ (y1, y2) | y1 <- f x1, y2 <- g x2]
    LA f &&& LA g       = LA $ \ x         -> [ (y1, y2) | y1 <- f x , y2 <- g x ]

instance ArrowZero LA where
    zeroArrow           = LA $ const []
    {-# INLINE zeroArrow #-}


instance ArrowPlus LA where
    LA f <+> LA g       = LA $ \ x -> f x ++ g x
    {-# INLINE (<+>) #-}

instance ArrowChoice LA where
    left  (LA f)        = LA $ either (map Left . f) ((:[]) . Right)
    right (LA f)        = LA $ either ((:[]) . Left) (map Right . f)
    LA f +++ LA g       = LA $ either (map Left . f) (map Right . g)
    LA f ||| LA g       = LA $ either f g


instance ArrowApply LA where
    app                 = LA $ \ (LA f, x) -> f x
    {-# INLINE app #-}

instance ArrowList LA where
    arrL                = LA
    {-# INLINE arrL #-}
    arr2A f             = LA $ \ ~(x, y) -> runLA (f x) y
    {-# INLINE arr2A #-}
    isA p               = LA $ \ x -> if p x then [x] else []
    {-# INLINE isA #-}
    LA f >>. g          = LA $ g . f
    {-# INLINE (>>.) #-}
    withDefault a d     = a >>. \ x -> if null x then [d] else x

instance ArrowIf LA where
    ifA (LA p) t e      = LA $ \ x -> runLA ( if null (p x)
                                              then e
                                              else t
                                            ) x
    {-# INLINE ifA #-}

    (LA f) `orElse` (LA g)
                        = LA $ \ x -> ( let
                                        res = f x
                                        in
                                        if null res
                                        then g x
                                        else res
                                      )
    {-# INLINE orElse #-}

    spanA p             = LA $ (:[]) . span (not . null . runLA p)

    partitionA  p       = LA $ (:[]) . partition (not . null . runLA p)

instance ArrowTree LA

instance ArrowNavigatableTree LA

instance ArrowNF LA where
    rnfA (LA f)         = LA $ \ x -> let res = f x
                                      in
                                      res `deepseq` res

instance ArrowWNF LA

-- ------------------------------------------------------------

-- | conversion of pure list arrows into other possibly more complex
-- list arrows

fromLA          :: ArrowList a => LA b c -> a b c
fromLA f        =  arrL (runLA f)
{-# INLINE fromLA #-}

-- ------------------------------------------------------------

