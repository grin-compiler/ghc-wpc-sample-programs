-- ------------------------------------------------------------

{- |
   Module     : Text.XML.HXT.DOM.FormatXmlTree
   Copyright  : Copyright (C) 2008 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : stable
   Portability: portable

   Format a xml tree in tree representation

-}

-- ------------------------------------------------------------

module Text.XML.HXT.DOM.FormatXmlTree
    ( formatXmlTree
    , formatXmlContents
    )
where

import Data.Maybe

import Text.XML.HXT.DOM.Interface
import Text.XML.HXT.DOM.ShowXml
import Text.XML.HXT.DOM.XmlNode

-- ------------------------------------------------------------


formatXmlContents       :: XmlTree -> XmlTrees
formatXmlContents t
    = [mkText (formatXmlTree t)]

formatXmlTree           :: XmlTree  -> String
formatXmlTree
    = formatTree xnode2String

xnode2String    :: XNode -> String
xnode2String n
    | isElem n
        = "XTag " ++ showName n ++ showAtts n
    | isPi n
        = "XPi "  ++ showName n ++ showAtts n
    | otherwise
        = show n
    where

showName        :: XNode -> String
showName        = maybe "" show . getName

showAtts        :: XNode -> String
showAtts        = concatMap showAl . fromMaybe [] . getAttrl

showAl          :: XmlTree -> String
showAl t        -- (NTree (XAttr an) av)
    | isAttr t
        = "\n|   " ++ (maybe "" show . getName $ t) ++ "=" ++ show (xshow . getChildren $ t)
    | otherwise
        = show t

-- ------------------------------------------------------------

