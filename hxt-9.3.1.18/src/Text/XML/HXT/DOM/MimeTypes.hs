-- ------------------------------------------------------------

{- |
   Module     : Text.XML.HXT.DOM.MimeTypes
   Copyright  : Copyright (C) 2008 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : experimental
   Portability: portable

   mime type related data and functions

-}

-- ------------------------------------------------------------

module Text.XML.HXT.DOM.MimeTypes
where

import           Control.Monad          ( mplus )

import qualified Data.ByteString        as B
import qualified Data.ByteString.Char8  as C

import           Data.Char
import           Data.List
import qualified Data.Map               as M
import           Data.Maybe

import           Text.XML.HXT.DOM.MimeTypeDefaults

-- ------------------------------------------------------------

type MimeTypeTable      = M.Map String String

-- ------------------------------------------------------------

-- mime types
--
-- see RFC \"http:\/\/www.rfc-editor.org\/rfc\/rfc3023.txt\"

application_xhtml,
 application_xml,
 application_xml_external_parsed_entity,
 application_xml_dtd,
 text_html,
 text_pdf,
 text_plain,
 text_xdtd,
 text_xml,
 text_xml_external_parsed_entity        :: String

application_xhtml                       = "application/xhtml+xml"
application_xml                         = "application/xml"
application_xml_external_parsed_entity  = "application/xml-external-parsed-entity"
application_xml_dtd                     = "application/xml-dtd"

text_html                               = "text/html"
text_pdf                                = "text/pdf"
text_plain                              = "text/plain"
text_xdtd                               = "text/x-dtd"
text_xml                                = "text/xml"
text_xml_external_parsed_entity         = "text/xml-external-parsed-entity"

isTextMimeType                          :: String -> Bool
isTextMimeType                          = ("text/" `isPrefixOf`)

isHtmlMimeType                          :: String -> Bool
isHtmlMimeType t                        = t == text_html

isXmlMimeType                           :: String -> Bool
isXmlMimeType t                         = ( t `elem` [ application_xhtml
                                                     , application_xml
                                                     , application_xml_external_parsed_entity
                                                     , application_xml_dtd
                                                     , text_xml
                                                     , text_xml_external_parsed_entity
                                                     , text_xdtd
                                                     ]
                                            ||
                                            "+xml" `isSuffixOf` t               -- application/mathml+xml
                                          )                                     -- or image/svg+xml

defaultMimeTypeTable                    :: MimeTypeTable
defaultMimeTypeTable                    = M.fromList mimeTypeDefaults

extensionToMimeType                     :: String -> MimeTypeTable -> String
extensionToMimeType e                   = fromMaybe "" . lookupMime
    where
    lookupMime t                        = M.lookup e t                  -- try exact match
                                          `mplus`
                                          M.lookup (map toLower e) t    -- else try lowercase match
                                          `mplus`
                                          M.lookup (map toUpper e) t    -- else try uppercase match

-- ------------------------------------------------------------

readMimeTypeTable                       :: FilePath -> IO MimeTypeTable
readMimeTypeTable inp                   = do
                                          cb <- B.readFile inp
                                          return . M.fromList . parseMimeTypeTable . C.unpack $ cb

parseMimeTypeTable                      :: String -> [(String, String)]
parseMimeTypeTable                      = concat
                                          . map buildPairs
                                          . map words
                                          . filter (not . ("#" `isPrefixOf`))
                                          . filter (not . all (isSpace))
                                          . lines
    where
    buildPairs                          :: [String] -> [(String, String)]
    buildPairs  []                      = []
    buildPairs  (mt:exts)               = map (\ x -> (x, mt)) $ exts

-- ------------------------------------------------------------
