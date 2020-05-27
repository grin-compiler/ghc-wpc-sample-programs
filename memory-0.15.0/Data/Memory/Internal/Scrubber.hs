-- |
-- Module      : Data.Memory.Internal.Scrubber
-- License     : BSD-style
-- Maintainer  : Vincent Hanquez <vincent@snarc.org>
-- Stability   : stable
-- Portability : Compat
--
{-# LANGUAGE CPP #-}
{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE MagicHash #-}
{-# LANGUAGE UnboxedTuples #-}
#include "MachDeps.h"
module Data.Memory.Internal.Scrubber
    ( getScrubber
    ) where

import GHC.Prim
import Data.Memory.Internal.CompatPrim (booleanPrim)

getScrubber :: Int# -> (Addr# -> State# RealWorld -> State# RealWorld)
getScrubber sz 
    | booleanPrim (sz ==# 4#)  = scrub4
    | booleanPrim (sz ==# 8#)  = scrub8
    | booleanPrim (sz ==# 16#) = scrub16
    | booleanPrim (sz ==# 32#) = scrub32
    | otherwise                = scrubBytes sz
  where
        scrub4 a = \s -> writeWord32OffAddr# a 0# 0## s
        {-# INLINE scrub4 #-}
#if WORD_SIZE_IN_BITS == 64
        scrub8 a = \s -> writeWord64OffAddr# a 0# 0## s
        {-# INLINE scrub8 #-}
        scrub16 a = \s1 ->
            let !s2 = writeWord64OffAddr# a 0# 0## s1
                !s3 = writeWord64OffAddr# a 1# 0## s2
             in s3
        {-# INLINE scrub16 #-}
        scrub32 a = \s1 ->
            let !s2 = writeWord64OffAddr# a 0# 0## s1
                !s3 = writeWord64OffAddr# a 1# 0## s2
                !s4 = writeWord64OffAddr# a 2# 0## s3
                !s5 = writeWord64OffAddr# a 3# 0## s4
             in s5
        {-# INLINE scrub32 #-}
#else
        scrub8 a = \s1 ->
            let !s2 = writeWord32OffAddr# a 0# 0## s1
                !s3 = writeWord32OffAddr# a 1# 0## s2
             in s3
        {-# INLINE scrub8 #-}
        scrub16 a = \s1 ->
            let !s2 = writeWord32OffAddr# a 0# 0## s1
                !s3 = writeWord32OffAddr# a 1# 0## s2
                !s4 = writeWord32OffAddr# a 2# 0## s3
                !s5 = writeWord32OffAddr# a 3# 0## s4
             in s5
        {-# INLINE scrub16 #-}
        scrub32 a = \s1 ->
            let !s2 = writeWord32OffAddr# a 0# 0## s1
                !s3 = writeWord32OffAddr# a 1# 0## s2
                !s4 = writeWord32OffAddr# a 2# 0## s3
                !s5 = writeWord32OffAddr# a 3# 0## s4
                !s6 = writeWord32OffAddr# a 4# 0## s5
                !s7 = writeWord32OffAddr# a 5# 0## s6
                !s8 = writeWord32OffAddr# a 6# 0## s7
                !s9 = writeWord32OffAddr# a 7# 0## s8
             in s9
        {-# INLINE scrub32 #-}
#endif

scrubBytes :: Int# -> Addr# -> State# RealWorld -> State# RealWorld
scrubBytes sz8 addr = \s -> loop sz8 addr s
  where loop :: Int# -> Addr# -> State# RealWorld -> State# RealWorld
        loop n a s
            | booleanPrim (n ==# 0#) = s
            | otherwise              =
                case writeWord8OffAddr# a 0# 0## s of
                    s' -> loop (n -# 1#) (plusAddr# a 1#) s'
        {-# INLINE loop #-}
{-# INLINE scrubBytes #-}
