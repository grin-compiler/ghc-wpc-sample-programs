-- ------------------------------------------------------------

{- |
   Module     : Text.XML.HXT.DOM.Interface
   Copyright  : Copyright (C) 2008 Uwe Schmidt
   License    : MIT


   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : stable
   Portability: portable

   The interface to the primitive DOM data types and constants
   and utility functions

-}

-- ------------------------------------------------------------

module Text.XML.HXT.DOM.Interface
    ( module Text.XML.HXT.DOM.XmlKeywords
    , module Text.XML.HXT.DOM.TypeDefs
    , module Text.XML.HXT.DOM.Util
    , module Text.XML.HXT.DOM.MimeTypes
    , module Data.String.EncodingNames
    )
where

import Text.XML.HXT.DOM.XmlKeywords             -- constants
import Text.XML.HXT.DOM.TypeDefs                -- XML Tree types
import Text.XML.HXT.DOM.Util
import Text.XML.HXT.DOM.MimeTypes               -- mime types related stuff

import Data.String.EncodingNames                -- char encoding names for readDocument

-- ------------------------------------------------------------
