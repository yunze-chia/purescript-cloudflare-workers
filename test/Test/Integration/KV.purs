module Test.Integration.KV where

import Prelude
import Affjax.Node (defaultRequest, printError, request)
import Affjax.ResponseFormat (json, string)
import Affjax.StatusCode (StatusCode(..))
import Data.Argonaut.Decode (decodeJson, printJsonDecodeError)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Test.Spec (Spec, before_, describe, it, sequential)
import Test.Spec.Assertions (fail, shouldEqual)
import Worker.KV (ListResult)

miniflareHost :: String
miniflareHost = "http://localhost:8787"

wipeKV :: Aff Unit
wipeKV = void $ request defaultRequest { url = miniflareHost <> "/delete" }

spec :: Spec Unit
spec = do
  -- These tests require a miniflare instance serving worker.test.mjs.
  describe "Integration.KV CRUD operations"
    $ sequential do
        before_ wipeKV
          $ it "Read operation with Worker.KV (get)" do
              maybeResp <- request defaultRequest { url = miniflareHost <> "/read" }
              case maybeResp of
                Left e -> fail $ printError e
                Right resp -> resp.status `shouldEqual` StatusCode 404
        it "Create operation with Worker.KV (put)" do
          maybeCreateResp <- request defaultRequest { url = miniflareHost <> "/create" }
          case maybeCreateResp of
            Left e -> fail $ printError e
            Right createResp -> do
              createResp.status `shouldEqual` StatusCode 200
              maybeReadResp <- request defaultRequest { url = miniflareHost <> "/read", responseFormat = string }
              case maybeReadResp of
                Left e -> fail $ printError e
                Right readResp -> do
                  readResp.status `shouldEqual` StatusCode 200
                  readResp.body `shouldEqual` "somevalue"
        it "Update operation with Worker.KV (put)" do
          maybeUpdateResp <- request defaultRequest { url = miniflareHost <> "/update" }
          case maybeUpdateResp of
            Left e -> fail $ printError e
            Right updateResp -> do
              updateResp.status `shouldEqual` StatusCode 200
              maybeReadResp <- request defaultRequest { url = miniflareHost <> "/read", responseFormat = string }
              case maybeReadResp of
                Left e -> fail $ printError e
                Right readResp -> do
                  readResp.status `shouldEqual` StatusCode 200
                  readResp.body `shouldEqual` "someothervalue"
        it "Delete operation with Worker.KV (delete)" do
          maybeDeleteResp <- request defaultRequest { url = miniflareHost <> "/delete" }
          case maybeDeleteResp of
            Left e -> fail $ printError e
            Right deleteResp -> do
              deleteResp.status `shouldEqual` StatusCode 200
              maybeReadResp <- request defaultRequest { url = miniflareHost <> "/read" }
              case maybeReadResp of
                Left e -> fail $ printError e
                Right readResp -> readResp.status `shouldEqual` StatusCode 404
  describe "Integration.KV list operations" do
    before_ wipeKV
      $ it "Read operation with Worker.KV (list) returning nothing" do
          maybeListResp <- request defaultRequest { url = miniflareHost <> "/list", responseFormat = json }
          case maybeListResp of
            Left e -> fail $ printError e
            Right listResp -> do
              listResp.status `shouldEqual` StatusCode 200
              case decodeJson listResp.body of
                Left decodeError -> fail $ printJsonDecodeError decodeError
                Right (listResult :: ListResult) ->
                  listResult
                    `shouldEqual`
                      { keys: [], list_complete: true, cursor: Nothing }
    it "Read operation with Worker.KV (list) returning some" do
      void $ request defaultRequest { url = miniflareHost <> "/create" }
      maybeListResp <- request defaultRequest { url = miniflareHost <> "/list", responseFormat = json }
      case maybeListResp of
        Left e -> fail $ printError e
        Right listResp -> do
          listResp.status `shouldEqual` StatusCode 200
          case decodeJson listResp.body of
            Left decodeError -> fail $ printJsonDecodeError decodeError
            Right (listResult :: ListResult) ->
              listResult
                `shouldEqual`
                  { keys: [ { name: "somekey" } ], list_complete: true, cursor: Nothing }
