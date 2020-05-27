-- ------------------------------------------------------------

{- |
   Module     : Text.XML.HXT.Arrow.Binary
   Copyright  : Copyright (C) 2008 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : experimental
   Portability: portable

   De-/Serialisation arrows for XmlTrees and other arbitrary values with a Binary instance
-}

-- ------------------------------------------------------------

module Text.XML.HXT.Arrow.Binary
    ( readBinaryValue
    , writeBinaryValue
    )
where

import           Control.Arrow                             ()
import           Control.Arrow.ArrowExc
import           Control.Arrow.ArrowIO
import           Control.Arrow.ArrowList

import           Data.Binary
import qualified Data.ByteString.Lazy                      as B

import           System.IO                                 (IOMode (..), hClose,
                                                            openBinaryFile)

import           Text.XML.HXT.Arrow.XmlState.ErrorHandling
import           Text.XML.HXT.Arrow.XmlState.TypeDefs

-- ------------------------------------------------------------

readBinaryValue         :: (Binary a) => String -> IOStateArrow s b a
readBinaryValue file
                        = (uncurry $ decodeBinaryValue file)
                          $< getSysVar ( theStrictDeserialize
                                         .&&&.
                                         theBinaryDeCompression
                                       )

-- | Read a serialied value from a file, optionally decompress it and decode the value
-- In case of an error, the error message is issued and the arrow fails

decodeBinaryValue         :: (Binary a) => String -> Bool -> DeCompressionFct -> IOStateArrow s b a
decodeBinaryValue file strict decompress
                          = arrIO0 dec
                            `catchA`
                            issueExc "readBinaryValue"
    where
    dec                 = ( if strict
                            then readItAll
                            else B.readFile file
                          ) >>= return . decode . decompress
    readItAll           = do
                          h <- openBinaryFile file ReadMode
                          c <- B.hGetContents h
                          B.length c `seq`
                           do
                           hClose h
                           return c     -- hack: force reading whole file and close it immediately

-- | Serialize a value, optionally compress it, and write it to a file.
-- In case of an error, the error message is issued and the arrow fails

writeBinaryValue        :: (Binary a) => String -> IOStateArrow s a ()
writeBinaryValue file   = flip encodeBinaryValue file $< getSysVar theBinaryCompression

encodeBinaryValue        :: (Binary a) => CompressionFct -> String -> IOStateArrow s a ()
encodeBinaryValue compress file
                         = arrIO enc
                           `catchA`
                           issueExc "writeBinaryXmlTree"
    where
    enc                  = B.writeFile file . compress . encode

-- ------------------------------------------------------------
