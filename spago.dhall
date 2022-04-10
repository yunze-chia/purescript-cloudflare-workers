{ name = "cloudflare-workers"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "affjax"
  , "argonaut-codecs"
  , "argonaut-core"
  , "effect"
  , "either"
  , "foreign"
  , "maybe"
  , "prelude"
  , "spec"
  , "spec-discovery"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
