module Worker.KV
  ( KV
  , ListOptions
  , ListResult
  , PutOptions
  , defaultListOptions
  , defaultPutOptions
  , delete
  , get
  , kvBinding
  , list
  , put
  ) where

import Prelude
import Control.Promise (Promise, toAffE)
import Data.Argonaut.Encode (class EncodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Foreign (Foreign, isNull, unsafeFromForeign)
import Worker.Core (Environment)
import Worker.Internal (unsafeToValueOrUndefined)

foreign import data KV :: Type

foreign import kvBindingImpl ::
  (forall x. x -> Maybe x) ->
  (forall x. Maybe x) ->
  Environment -> String -> Maybe KV

kvBinding :: Environment -> String -> Maybe KV
kvBinding = kvBindingImpl Just Nothing

type PutOptions a
  = { expiration :: Maybe Int
    , expirationTtl :: Maybe Int
    , metadata :: Maybe a
    }

defaultPutOptions :: forall a. PutOptions a
defaultPutOptions = { expiration: Nothing, expirationTtl: Nothing, metadata: Nothing }

foreign import putImpl ::
  (forall x. String -> Either String x) ->
  (forall x. x -> Either String x) ->
  KV -> String -> String -> Foreign -> Foreign -> Foreign -> Effect (Promise (Either String Unit))

put :: forall a. EncodeJson a => KV -> String -> String -> PutOptions a -> Aff (Either String Unit)
put kv key value options =
  toAffE
    $ putImpl Left Right kv key value
        (unsafeToValueOrUndefined options.expiration)
        (unsafeToValueOrUndefined options.expirationTtl)
        (unsafeToValueOrUndefined options.metadata)

foreign import getImpl ::
  (forall x. String -> Either String x) ->
  (forall x. x -> Either String x) ->
  KV -> String -> Effect (Promise (Either String Foreign))

-- TODO: implement streaming
get :: forall a. KV -> String -> Aff (Either String (Maybe a))
get kv key = do
  eitherForeign <- toAffE $ getImpl Left Right kv key
  pure $ wrapNull <$> eitherForeign
  where
  wrapNull v = if isNull v then Nothing else Just (unsafeFromForeign v)

foreign import deleteImpl ::
  (forall x. String -> Either String x) ->
  (forall x. x -> Either String x) ->
  KV -> String -> Effect (Promise (Either String Unit))

delete :: KV -> String -> Aff (Either String Unit)
delete kv key = toAffE $ deleteImpl Left Right kv key

type ListOptions
  = { prefix :: Maybe String, limit :: Maybe Int, cursor :: Maybe String }

defaultListOptions :: ListOptions
defaultListOptions = { prefix: Nothing, limit: Nothing, cursor: Nothing }

type ListResult_
  = { keys :: Array { name :: String }
    , list_complete :: Boolean
    , cursor :: String -- Empty string if nothing
    }

type ListResult
  = { keys :: Array { name :: String }
    , list_complete :: Boolean
    , cursor :: Maybe String
    }

foreign import listImpl ::
  (forall x. String -> Either String x) ->
  (forall x. x -> Either String x) ->
  KV -> Foreign -> Foreign -> Foreign -> Effect (Promise (Either String ListResult_))

list :: KV -> ListOptions -> Aff (Either String ListResult)
list kv { prefix, limit, cursor } = do
  result <-
    toAffE
      $ listImpl Left Right kv
          (unsafeToValueOrUndefined prefix)
          (unsafeToValueOrUndefined limit)
          (unsafeToValueOrUndefined cursor)
  pure $ tidyUpResult <$> result
  where
  tidyUpResult listResult@{ cursor: c } = listResult { cursor = if c == "" then Nothing else Just c }
