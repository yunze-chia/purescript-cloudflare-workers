module Example.Basic.Main where

import Prelude
import Control.Monad.Reader (runReaderT)
import Control.Promise (Promise, fromAff)
import Data.Argonaut.Core (stringify)
import Data.Argonaut.Encode (encodeJson)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Utils (extractPath)
import Worker.Core (Application, Context, Environment, Header(..), Middleware, Request, Response_, StatusCode(..), defaultResponse, makeResponse)

-- This is the entrypoint to our app. It is exported as a promise and called by worker.mjs.
run :: Request -> Environment -> Context -> Effect (Promise Response_)
run req env _ = fromAff $ makeResponse <$> runReaderT (app req) env
  where
  app = withLogging application

application :: Application
application req = case extractPath req.url of
  Just "/hello" -> handlerHello req
  _ -> pure defaultResponse { status = StatusCode 404 }

withLogging :: Middleware
withLogging app req = do
  liftEffect $ log $ req.method <> " " <> req.url
  app req

handlerHello :: Application
handlerHello _ = do
  let
    body = encodeJson { success: true, message: "hello" }
  pure defaultResponse { body = stringify body, headers = [ Header "content-type" "application/json" ] }
