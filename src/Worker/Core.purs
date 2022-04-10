module Worker.Core where

import Control.Monad.Reader (ReaderT)
import Effect.Aff (Aff)

type Request
  = { body :: String, headers :: Array Header, method :: String, url :: String }

type Response
  = { body :: String, status :: StatusCode, headers :: Array Header }

defaultResponse :: Response
defaultResponse = { body: "", status: StatusCode 200, headers: [] }

data Header
  = Header String String

newtype StatusCode
  = StatusCode Int

type Application
  = Request -> HandlerM Response

type Middleware
  = Application -> Application

type HandlerM
  = ReaderT Environment Aff

-- Environment holds bindings assigned to the worker
-- https://developers.cloudflare.com/workers/platform/environment-variables/
foreign import data Environment :: Type

foreign import data Context :: Type

foreign import data Response_ :: Type

foreign import makeResponse :: Response -> Response_
