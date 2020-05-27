-- ------------------------------------------------------------

{- |
   Module     : Text.XML.HXT.DOM.Util
   Copyright  : Copyright (C) 2008 Uwe Schmidt
   License    : MIT

   Maintainer : Uwe Schmidt (uwe@fh-wedel.de)
   Stability  : stable
   Portability: portable

   Little useful things for strings, lists and other values

-}

-- ------------------------------------------------------------

module Text.XML.HXT.DOM.Util
    ( stringTrim
    , stringToLower
    , stringToUpper
    , stringAll
    , stringFirst
    , stringLast

    , normalizeNumber
    , normalizeWhitespace
    , normalizeBlanks

    , escapeURI
    , textEscapeXml
    , stringEscapeXml
    , attrEscapeXml

    , stringToInt
    , stringToHexString
    , charToHexString
    , intToHexString
    , hexStringToInt
    , decimalStringToInt

    , doubles
    , singles
    , noDoubles

    , swap
    , partitionEither
    , toMaybe

    , uncurry3
    , uncurry4
    )
where

import           Data.Char
import           Data.List
import           Data.Maybe

-- ------------------------------------------------------------

-- |
-- remove leading and trailing whitespace with standard Haskell predicate isSpace

stringTrim              :: String -> String
stringTrim              = reverse . dropWhile isSpace . reverse . dropWhile isSpace

-- |
-- convert string to uppercase with standard Haskell toUpper function

stringToUpper           :: String -> String
stringToUpper           = map toUpper

-- |
-- convert string to lowercase with standard Haskell toLower function

stringToLower           :: String -> String
stringToLower           = map toLower


-- | find all positions where a string occurs within another string

stringAll       :: (Eq a) => [a] -> [a] -> [Int]
stringAll x     = map fst . filter ((x `isPrefixOf`) . snd) . zip [0..] . tails

-- | find the position of the first occurence of a string

stringFirst     :: (Eq a) => [a] -> [a] -> Maybe Int
stringFirst x   = listToMaybe . stringAll x

-- | find the position of the last occurence of a string

stringLast      :: (Eq a) => [a] -> [a] -> Maybe Int
stringLast x    = listToMaybe . reverse . stringAll x

-- ------------------------------------------------------------
-- | Removes leading \/ trailing whitespaces and leading zeros

normalizeNumber         :: String -> String
normalizeNumber
    = reverse . dropWhile (== ' ') . reverse .
      dropWhile (\x -> x == '0' || x == ' ')

-- | Reduce whitespace sequences to a single whitespace

normalizeWhitespace     :: String -> String
normalizeWhitespace     = unwords . words

-- | replace all whitespace chars by blanks

normalizeBlanks         :: String -> String
normalizeBlanks         = map (\ x -> if isSpace x then ' ' else x)

-- ------------------------------------------------------------

-- | Escape all disallowed characters in URI
-- references (see <http://www.w3.org/TR/xlink/#link-locators>)

escapeURI :: String -> String
escapeURI ref
    = concatMap replace ref
      where
      notAllowed        :: Char -> Bool
      notAllowed c
          = c < '\31'
            ||
            c `elem` ['\DEL', ' ', '<', '>', '\"', '{', '}', '|', '\\', '^', '`' ]

      replace :: Char -> String
      replace c
          | notAllowed c
              = '%' : charToHexString c
          | otherwise
              = [c]

-- ------------------------------------------------------------

escapeXml               :: String -> String -> String
escapeXml escSet
    = concatMap esc
      where
      esc c
          | c `elem` escSet
              = "&#" ++ show (fromEnum c) ++ ";"
          | otherwise
              = [c]

-- |
-- escape XML chars &lt;, &gt;, &quot;,  and ampercent by transforming them into character references
--
-- see also : 'attrEscapeXml'

stringEscapeXml :: String -> String
stringEscapeXml = escapeXml "<>\"\'&"

-- |
-- escape XML chars &lt;  and ampercent by transforming them into character references, used for escaping text nodes
--
-- see also : 'attrEscapeXml'

textEscapeXml           :: String -> String
textEscapeXml           = escapeXml "<&"

-- |
-- escape XML chars in attribute values, same as stringEscapeXml, but none blank whitespace
-- is also escaped
--
-- see also : 'stringEscapeXml'

attrEscapeXml           :: String -> String
attrEscapeXml           = escapeXml "<>\"\'&\n\r\t"

stringToInt             :: Int -> String -> Int
stringToInt base digits
    = sign * (foldl acc 0 $ concatMap digToInt digits1)
      where
      splitSign ('-' : ds) = ((-1), ds)
      splitSign ('+' : ds) = ( 1  , ds)
      splitSign ds         = ( 1  , ds)
      (sign, digits1)      = splitSign digits
      digToInt c
          | c >= '0' && c <= '9'
              = [ord c - ord '0']
          | c >= 'A' && c <= 'Z'
              =  [ord c - ord 'A' + 10]
          | c >= 'a' && c <= 'z'
              =  [ord c - ord 'a' + 10]
          | otherwise
              = []
      acc i1 i0
          = i1 * base + i0


-- |
-- convert a string of hexadecimal digits into an Int

hexStringToInt          :: String -> Int
hexStringToInt          = stringToInt 16

-- |
-- convert a string of digits into an Int

decimalStringToInt      :: String -> Int
decimalStringToInt      = stringToInt 10

-- |
-- convert a string into a hexadecimal string applying charToHexString
--
-- see also : 'charToHexString'

stringToHexString       :: String -> String
stringToHexString       = concatMap charToHexString

-- |
-- convert a char (byte) into a 2-digit hexadecimal string
--
-- see also : 'stringToHexString', 'intToHexString'

charToHexString         :: Char -> String
charToHexString c
    = [ fourBitsToChar (c' `div` 16)
      , fourBitsToChar (c' `mod` 16)
      ]
    where
    c' = fromEnum c

-- |
-- convert a none negative Int into a hexadecimal string
--
-- see also : 'charToHexString'

intToHexString          :: Int -> String
intToHexString i
    | i == 0
        = "0"
    | i > 0
        = intToStr i
    | otherwise
        = error ("intToHexString: negative argument " ++ show i)
    where
    intToStr 0  = ""
    intToStr i' = intToStr (i' `div` 16) ++ [fourBitsToChar (i' `mod` 16)]

fourBitsToChar          :: Int -> Char
fourBitsToChar i        = "0123456789ABCDEF" !! i

-- ------------------------------------------------------------

-- |
-- take all elements of a list which occur more than once. The result does not contain doubles.
-- (doubles . doubles == doubles)

doubles :: Eq a => [a] -> [a]
doubles
    = doubles' []
      where
      doubles' acc []
          = acc
      doubles' acc (e : s)
          | e `elem` s
            &&
            e `notElem` acc
              = doubles' (e:acc) s
          | otherwise
              = doubles' acc s

-- |
-- drop all elements from a list which occur more than once.

singles :: Eq a => [a] -> [a]
singles
    = singles' []
      where
      singles' acc []
          = acc
      singles' acc (e : s)
          | e `elem` s
            ||
            e `elem` acc
              = singles' acc s
          | otherwise
              = singles' (e : acc) s

-- |
-- remove duplicates from list

noDoubles :: Eq a => [a] -> [a]
noDoubles []
    = []
noDoubles (e : s)
    | e `elem` s = noDoubles s
    | otherwise  = e : noDoubles s

-- ------------------------------------------------------------

swap :: (a,b) -> (b,a)
swap (x,y) = (y,x)

partitionEither :: [Either a b] -> ([a], [b])
partitionEither =
   foldr (\x ~(ls,rs) -> either (\l -> (l:ls,rs)) (\r -> (ls,r:rs)) x) ([],[])

toMaybe :: Bool -> a -> Maybe a
toMaybe False _ = Nothing
toMaybe True  x = Just x

-- ------------------------------------------------------------

-- | mothers little helpers for to much curry

uncurry3                        :: (a -> b -> c -> d) -> (a, b, c) -> d
uncurry3 f ~(a, b, c)           = f a b c

uncurry4                        :: (a -> b -> c -> d -> e) -> (a, b, c, d) -> e
uncurry4 f ~(a, b, c, d)        = f a b c d

-- ------------------------------------------------------------
