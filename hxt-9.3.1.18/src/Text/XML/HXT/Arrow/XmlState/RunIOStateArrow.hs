-- ------------------------------------------------------------

{- |
   Module     : Text.XML.HXT.Arrow.XmlState.RunIOStateArrow
   Copyright  : Copyright (C) 2010 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : stable
   Portability: portable

   run an io state arrow
-}

-- ------------------------------------------------------------

module Text.XML.HXT.Arrow.XmlState.RunIOStateArrow
where

import Control.Arrow                            -- arrow classes
import Control.Arrow.ArrowList
import Control.Arrow.IOStateListArrow

import Data.Map                                 ( empty )
import Text.XML.HXT.DOM.Interface

import Text.XML.HXT.Arrow.XmlArrow
import Text.XML.HXT.Arrow.XmlState.ErrorHandling
import Text.XML.HXT.Arrow.XmlState.TraceHandling
import Text.XML.HXT.Arrow.XmlState.TypeDefs

-- ------------------------------------------------------------

-- |
-- apply an 'IOSArrow' to an empty root node with 'initialState' () as initial state
--
-- the main entry point for running a state arrow with IO
--
-- when running @ runX f@ an empty XML root node is applied to @f@.
-- usually @f@ will start with a constant arrow (ignoring the input), e.g. a 'Text.XML.HXT.Arrow.ReadDocument.readDocument' arrow.
--
-- for usage see examples with 'Text.XML.HXT.Arrow.WriteDocument.writeDocument'
--
-- if input has to be feed into the arrow use 'Control.Arrow.IOStateListArrow.runIOSLA' like in @ runIOSLA f emptyX inputDoc @

runX            :: IOSArrow XmlTree c -> IO [c]
runX            = runXIOState (initialState ())


runXIOState     :: XIOState s -> IOStateArrow s XmlTree c -> IO [c]
runXIOState s0 f
    = do
      (_finalState, res) <- runIOSLA (emptyRoot >>> f) s0 undefined
      return res
    where
    emptyRoot    = root [] []


-- | the default global state, used as initial state when running an 'IOSArrow' with 'runIOSLA' or
-- 'runX'

initialState    :: us -> XIOState us
initialState s  = XIOState { xioSysState       = initialSysState
                           , xioUserState      = s
                           }

-- ------------------------------------------------------------

initialSysState                 :: XIOSysState
initialSysState                 = XIOSys
                                  { xioSysWriter         = initialSysWriter
                                  , xioSysEnv            = initialSysEnv
                                  }

initialSysWriter                :: XIOSysWriter
initialSysWriter                = XIOwrt
                                  { xioErrorStatus       = c_ok
                                  , xioErrorMsgList      = []
                                  , xioExpatErrors       = none
                                  , xioRelaxNoOfErrors   = 0
                                  , xioRelaxDefineId     = 0
                                  , xioRelaxAttrList     = []
                                  }

initialSysEnv                   :: XIOSysEnv
initialSysEnv                   = XIOEnv
                                  { xioTraceLevel        = 0
                                  , xioTraceCmd          = traceOutputToStderr
                                  , xioErrorMsgHandler   = errorOutputToStderr
                                  , xioErrorMsgCollect   = False
                                  , xioBaseURI           = ""
                                  , xioDefaultBaseURI    = ""
                                  , xioAttrList          = []
                                  , xioInputConfig       = initialInputConfig
                                  , xioParseConfig       = initialParseConfig
                                  , xioOutputConfig      = initialOutputConfig
                                  , xioRelaxConfig       = initialRelaxConfig
                                  , xioXmlSchemaConfig   = initialXmlSchemaConfig
                                  , xioCacheConfig       = initialCacheConfig
                                  }

initialInputConfig              :: XIOInputConfig
initialInputConfig              = XIOIcgf
                                  { xioStrictInput       = False
                                  , xioEncodingErrors    = True
                                  , xioInputEncoding     = ""
                                  , xioHttpHandler       = dummyHTTPHandler
                                  , xioInputOptions      = []
                                  , xioRedirect          = False
                                  , xioProxy             = ""
                                  }

initialParseConfig              :: XIOParseConfig
initialParseConfig              = XIOPcfg
                                  { xioMimeTypes                = defaultMimeTypeTable
                                  , xioMimeTypeHandlers         = empty
                                  , xioMimeTypeFile             = ""
                                  , xioAcceptedMimeTypes        = []
                                  , xioFileMimeType             = ""
                                  , xioWarnings                 = True
                                  , xioRemoveWS                 = False
                                  , xioParseByMimeType          = False
                                  , xioParseHTML                = False
                                  , xioLowerCaseNames           = False
                                  , xioTagSoup                  = False
                                  , xioPreserveComment          = False
                                  , xioValidate                 = True
                                  , xioSubstDTDEntities         = True
                                  , xioSubstHTMLEntities        = False
                                  , xioCheckNamespaces          = False
                                  , xioCanonicalize             = True
                                  , xioIgnoreNoneXmlContents    = False
                                  , xioTagSoupParser            = dummyTagSoupParser
                                  , xioExpat                    = False
                                  , xioExpatParser              = dummyExpatParser
                                  }

initialOutputConfig             :: XIOOutputConfig
initialOutputConfig             = XIOOcfg
                                  { xioIndent                   = False
                                  , xioOutputEncoding           = ""
                                  , xioOutputFmt                = XMLoutput
                                  , xioXmlPi                    = True
                                  , xioNoEmptyElemFor           = []
                                  , xioAddDefaultDTD            = False
                                  , xioTextMode                 = False
                                  , xioShowTree                 = False
                                  , xioShowHaskell              = False
                                  }

initialRelaxConfig              :: XIORelaxConfig
initialRelaxConfig              = XIORxc
                                  { xioRelaxValidate            = False
                                  , xioRelaxSchema              = ""
                                  , xioRelaxCheckRestr          = True
                                  , xioRelaxValidateExtRef      = True
                                  , xioRelaxValidateInclude     = True
                                  , xioRelaxCollectErrors       = True
                                  , xioRelaxValidator           = dummyRelaxValidator
                                  }

initialXmlSchemaConfig          :: XIOXmlSchemaConfig
initialXmlSchemaConfig          = XIOScc
                                  { xioXmlSchemaValidate        = False
                                  , xioXmlSchemaSchema          = ""
                                  , xioXmlSchemaValidator       = dummyXmlSchemaValidator
                                  }

initialCacheConfig              :: XIOCacheConfig
initialCacheConfig              = XIOCch
                                   { xioBinaryCompression       = id
                                   , xioBinaryDeCompression     = id
                                   , xioWithCache               = False
                                   , xioCacheDir                = ""
                                   , xioDocumentAge             = 0
                                   , xioCache404Err             = False
                                   , xioCacheRead               = dummyCacheRead
                                   , xioStrictDeserialize       = False
                                   }

-- ------------------------------------------------------------

dummyHTTPHandler        :: IOSArrow XmlTree XmlTree
dummyHTTPHandler        = ( issueFatal $
                            unlines $
                            [ "HTTP handler not configured,"
                            , "please install package hxt-curl and use 'withCurl' config option"
                            , "or install package hxt-http and use 'withHTTP' config option"
                            ]
                          )
                          >>>
                          addAttr transferMessage "HTTP handler not configured"
                          >>>
                          addAttr transferStatus "999"


dummyTagSoupParser      :: IOSArrow b b
dummyTagSoupParser      =  issueFatal $
                           unlines $
                           [ "TagSoup parser not configured,"
                           , "please install package hxt-tagsoup"
                           , " and use 'withTagSoup' parser config option from this package"
                           ]

dummyExpatParser        :: IOSArrow b b
dummyExpatParser        =  issueFatal $
                           unlines $
                           [ "Expat parser not configured,"
                           , "please install package hxt-expat"
                           , " and use 'withExpat' parser config option from this package"
                           ]

dummyRelaxValidator     :: IOSArrow b b
dummyRelaxValidator     =  issueFatal $
                           unlines $
                           [ "RelaxNG validator not configured,"
                           , "please install package hxt-relaxng"
                           , " and use 'withRelaxNG' config option from this package"
                           ]

dummyXmlSchemaValidator :: IOSArrow b b
dummyXmlSchemaValidator =  issueFatal $
                           unlines $
                           [ "XML Schema validator not configured,"
                           , "please install package hxt-xmlschema"
                           , " and use 'withXmlSchema' config option from this package"
                           ]

dummyCacheRead          :: String -> IOSArrow b b
dummyCacheRead          = const $
                          issueFatal $
                          unlines $
                          [ "Document cache not configured,"
                          , "please install package hxt-cache and use 'withCache' config option"
                          ]

-- ------------------------------------------------------------

getConfigAttr           :: String -> SysConfigList -> String
getConfigAttr n c       = lookup1 n $ tl
    where
    s                   = (foldr (>>>) id c) initialSysState
    tl                  = getS theAttrList s

-- ----------------------------------------

theSysConfigComp        :: Selector XIOSysState a -> Selector SysConfig a
theSysConfigComp sel    = S { getS = \     cf -> getS sel      (cf initialSysState)
                            , setS = \ val cf -> setS sel val . cf
                            }

-- ------------------------------------------------------------
