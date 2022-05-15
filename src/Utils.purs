module Utils
  ( extractPath
  ) where

import Data.Maybe (Maybe(..))

foreign import extractPathImpl :: (forall x. x -> Maybe x) -> (forall x. Maybe x) -> String -> Maybe String

extractPath :: String -> Maybe String
extractPath = extractPathImpl Just Nothing
