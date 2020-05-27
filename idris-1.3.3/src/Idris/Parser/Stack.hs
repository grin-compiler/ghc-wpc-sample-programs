{-|
Module      : Idris.Parser.Stack
Description : Idris parser stack and its primitives.

License     : BSD3
Maintainer  : The Idris Community.
-}
{-# LANGUAGE CPP, ConstraintKinds, FlexibleContexts, MultiParamTypeClasses #-}
module Idris.Parser.Stack
  ( -- * Parsing
    Parser(..)
  , Parsing(..)
  , runparser
    -- * Parse errors
  , ParseError
  , prettyError
    -- * Mark and restore
  , Mark
  , mark
  , restore

    -- * Tracking the extent of productions
    --
    -- The parser stack automatically builds up the extent of any parse from
    -- the extents of sub-parsers wrapped with @trackExtent@.
  , getFC
  , addExtent
  , trackExtent
  , extent
  , withExtent
  , appExtent
  )
where

import Idris.Core.TT (FC(..))
import Idris.Output (Message(..))

import Control.Arrow (app)
import qualified Control.Monad.Fail as Fail
import Control.Monad.State.Strict (StateT(..), evalStateT)
import Control.Monad.Writer.Strict (MonadWriter(..), WriterT(..), listen,
                                    runWriterT, tell)
import qualified Data.List.NonEmpty as NonEmpty
import Data.Void (Void(..))
import System.FilePath (addTrailingPathSeparator, splitFileName)
import qualified Text.Megaparsec as P
import qualified Util.Pretty as PP

{- * Parsing -}

-- | Our parser stack with state of type @s@
type Parser s = StateT s (WriterT FC (P.Parsec Void String))

-- | A constraint for parsing without state
type Parsing m = (Fail.MonadFail m, P.MonadParsec Void String m, MonadWriter FC m)

-- | Run the Idris parser stack
runparser :: Parser st res -> st -> String -> String -> Either ParseError res
runparser p i inputname s =
  case P.parse (runWriterT (evalStateT p i)) inputname s of
    Left err -> Left $ ParseError err
    Right v  -> Right $ fst v

{- * Parse errors -}

newtype ParseError = ParseError { unParseError :: P.ParseErrorBundle String Void }

parseError :: ParseError -> P.ParseError String Void
parseError = NonEmpty.head . P.bundleErrors . unParseError

parseErrorPosState :: ParseError -> P.PosState String
parseErrorPosState = P.bundlePosState . unParseError

parseErrorOffset :: ParseError -> Int
parseErrorOffset = P.errorOffset . parseError

instance Message ParseError where
  messageExtent err = sourcePositionFC pos
    where
#if MIN_VERSION_megaparsec(8,0,0)
      P.PosState {P.pstateSourcePos = pos} =
        P.reachOffsetNoLine (parseErrorOffset err) (parseErrorPosState err)
#else
      (pos, _) = P.reachOffsetNoLine (parseErrorOffset err) (parseErrorPosState err)
#endif
  messageText = PP.text . init . P.parseErrorTextPretty . parseError
  messageSource err = Just sline
    where
#if MIN_VERSION_megaparsec(8,0,0)
      (sline, _) = P.reachOffset (parseErrorOffset err) (parseErrorPosState err)
#else
      (_, sline, _) = P.reachOffset (parseErrorOffset err) (parseErrorPosState err)
#endif

-- | A fully formatted parse error, with caret and bar, etc.
prettyError :: ParseError -> String
prettyError =  P.errorBundlePretty . unParseError

{- * Mark and restore -}

#if MIN_VERSION_megaparsec(8,0,0)
type Mark = P.State String Void
#else
type Mark = P.State String
#endif

-- | Retrieve the parser state so we can restart from this point later.
mark :: Parsing m => m Mark
mark = P.getParserState

restore :: Parsing m => Mark -> m ()
restore = P.setParserState

{- * Tracking the extent of productions -}

sourcePositionFC :: P.SourcePos -> FC
sourcePositionFC (P.SourcePos name line column) =
  FC f (lineNumber, columnNumber) (lineNumber, columnNumber)
  where
    lineNumber = P.unPos line
    columnNumber = P.unPos column
    (dir, file) = splitFileName name
    f = if dir == addTrailingPathSeparator "."
        then file
        else name

-- | Get the current parse position.
--
-- This is useful when the position is needed in a way unrelated to the
-- heirarchy of parsers.  Prefer using @withExtent@ and friends.
getFC :: Parsing m => m FC
getFC = sourcePositionFC <$> P.getSourcePos

-- | Add an extent (widen) our current parsing context.
addExtent :: MonadWriter FC m => FC -> m ()
addExtent = tell

-- | Run a parser and track its extent.
--
-- Wrap bare Megaparsec parsers with this to make them "visible" in error
-- messages.  Do not wrap whitespace or comment parsers.  If you find an
-- extent is taking trailing whitespace, it's likely there's a double-wrapped
-- parser (usually via @Idris.Parser.Helpers.token@).
trackExtent :: Parsing m => m a -> m a
trackExtent p = do ~(FC f (sr, sc) _) <- getFC
                   result <- p
                   ~(FC f _ (er, ec)) <- getFC
                   addExtent (FC f (sr, sc) (er, max 1 (ec - 1)))
                   return result

-- | Run a parser, discard its value, and return its extent.
extent :: MonadWriter FC m => m a -> m FC
extent = fmap snd . withExtent

-- | Run a parser and return its value and extent.
withExtent :: MonadWriter FC m => m a -> m (a, FC)
withExtent = listen

-- | Run a parser and inject the extent after via function application.
appExtent :: MonadWriter FC m => m (FC -> a) -> m a
appExtent = fmap app . withExtent
