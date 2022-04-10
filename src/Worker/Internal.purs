module Worker.Internal
  ( debugStringify
  , unsafeToValueOrUndefined
  ) where

import Data.Maybe (Maybe(..))
import Foreign (Foreign, unsafeToForeign)

foreign import undefined :: Foreign

-- Use only on primitive types
unsafeToValueOrUndefined :: forall a. Maybe a -> Foreign
unsafeToValueOrUndefined = case _ of
  Just v -> unsafeToForeign v
  Nothing -> undefined

-- Helper for debugging only
foreign import debugStringify :: forall a. a -> String
