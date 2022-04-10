module Test.KVServer where

import Prelude
import Control.Monad.Reader (ask, lift, runReaderT)
import Control.Promise (Promise, fromAff)
import Data.Argonaut.Core (stringify)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Utils (extractPath)
import Worker.Core (Application, Context, Environment, Header(..), Request, Response_, StatusCode(..), defaultResponse, makeResponse)
import Worker.KV (PutOptions, defaultListOptions, defaultPutOptions, delete, get, kvBinding, list, put)

run :: Request -> Environment -> Context -> Effect (Promise Response_)
run req env _ = fromAff $ makeResponse <$> runReaderT (application req) env

application :: Application
application req = case extractPath req.url of
  Just "/create" -> handlerCreateOrUpdate "somevalue" req
  Just "/read" -> handlerRead req
  Just "/update" -> handlerCreateOrUpdate "someothervalue" req
  Just "/delete" -> handlerDelete req
  Just "/list" -> handlerList req
  _ -> pure defaultResponse { status = StatusCode 404 }

handlerCreateOrUpdate :: String -> Application
handlerCreateOrUpdate value _ = do
  env <- ask
  case kvBinding env "testkv" of
    Nothing -> pure defaultResponse { status = StatusCode 500 }
    Just kv -> do
      putResult <- lift $ put kv "somekey" value (defaultPutOptions :: PutOptions Unit)
      case putResult of
        Left e -> pure defaultResponse { status = StatusCode 500, body = e }
        Right _ -> pure defaultResponse

handlerRead :: Application
handlerRead _ = do
  env <- ask
  case kvBinding env "testkv" of
    Nothing -> pure defaultResponse { status = StatusCode 500 }
    Just kv -> do
      getResult <- lift $ get kv "somekey"
      case getResult of
        Right (Just v) -> pure defaultResponse { body = v }
        Right Nothing -> pure defaultResponse { status = StatusCode 404 }
        Left e -> pure defaultResponse { status = StatusCode 500, body = e }

handlerDelete :: Application
handlerDelete _ = do
  env <- ask
  case kvBinding env "testkv" of
    Nothing -> pure defaultResponse { status = StatusCode 500 }
    Just kv -> do
      deleteResult <- lift $ delete kv "somekey"
      case deleteResult of
        Left e -> pure defaultResponse { status = StatusCode 500, body = e }
        Right _ -> pure defaultResponse

handlerList :: Application
handlerList _ = do
  env <- ask
  case kvBinding env "testkv" of
    Nothing -> pure defaultResponse { status = StatusCode 500 }
    Just kv -> do
      listResult <- lift $ list kv defaultListOptions
      case listResult of
        Left e -> pure defaultResponse { status = StatusCode 500, body = e }
        Right v ->
          pure
            defaultResponse
              { body = stringify $ encodeJson v
              , headers = [ Header "content-type" "application/json" ]
              }
