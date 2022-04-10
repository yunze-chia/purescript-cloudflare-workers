module Utils
  ( extractPath
  ) where

import Data.Maybe (Maybe(..))

foreign import extractPath_ :: (forall x. x -> Maybe x) -> (forall x. Maybe x) -> String -> Maybe String

extractPath :: String -> Maybe String
extractPath = extractPath_ Just Nothing
