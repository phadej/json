--------------------------------------------------------------------
-- |
-- Module    : Text.JSON.Pretty
-- Copyright : (c) Galois, Inc. 2007
-- License   : BSD3
--
-- Maintainer:  Don Stewart <dons@galois.com>
-- Stability :  provisional
-- Portability: portable
--
-- Display JSON values using pretty printing combinators.

module Text.JSON.Pretty
  ( module Text.JSON.Pretty
  , module Text.PrettyPrint.HughesPJ
  ) where

import Text.JSON.Types
import Text.PrettyPrint.HughesPJ
import Data.Ratio
import Data.Char
import Numeric

pp_value         :: JSValue -> Doc
pp_value v        = case v of
    JSNull       -> pp_null
    JSBool x     -> pp_boolean x
    JSRational x -> pp_number x
    JSString x   -> pp_js_string x
    JSArray vs   -> pp_array vs
    JSObject xs  -> pp_js_object xs

pp_null          :: Doc
pp_null           = text "null"

pp_boolean       :: Bool -> Doc
pp_boolean True   = text "true"
pp_boolean False  = text "false"

pp_number        :: Rational -> Doc
pp_number x | denominator x == 1  = integer (numerator x)
pp_number x                       = double (fromRational x)

pp_array         :: [JSValue] -> Doc
pp_array xs       = brackets $ fsep $ punctuate comma $ map pp_value xs

pp_string        :: String -> Doc
pp_string x       = doubleQuotes $ hcat $ map pp_char x
  where pp_char '\\'            = text "\\\\"
        pp_char '"'             = text "\\\""
        pp_char c | isControl c || fromEnum c >= 0x7f = uni_esc c
        pp_char c               = char c

        uni_esc c = text "\\u" <> text (pad 4 (showHex (fromEnum c) ""))

        pad n cs  | len < n   = replicate (n-len) '0' ++ cs
                  | otherwise = cs
          where len = length cs

pp_object        :: [(String,JSValue)] -> Doc
pp_object xs      = braces $ fsep $ punctuate comma $ map pp_field xs
  where pp_field (k,v) = pp_string k <> colon <+> pp_value v

pp_js_string     :: JSString -> Doc
pp_js_string x    = pp_string (fromJSString x)

pp_js_object     :: JSObject JSValue -> Doc
pp_js_object x    = pp_object (fromJSObject x)

