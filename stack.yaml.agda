resolver: lts-15.6

allow-newer: true

packages:

- 'Agda-2.6.1'
- 'alex-3.2.5'
- 'regex-base-0.94.0.0'
- 'unordered-containers-0.2.10.0'

extra-deps:
- data-hash-0.2.0.1@sha256:0277d99cb8b535ecc375c59e55f1c91faab966d9167a946ef18445dd468ba727,1135
- equivalence-0.3.5@sha256:aedbd070b7ab5e58dd1678cd85607bc33cb9ff62331c1fa098ca45063b3072db,1626
- geniplate-mirror-0.7.7@sha256:6a698c1bcec25f4866999001c4de30049d4f8f00ec83f8930cda2f767489c637,1106
- STMonadTrans-0.4.4@sha256:437eec4fdf5f56e9cd4360e08ed7f8f9f5f02ff3f1d634a14dbc71e890035387,1946

flags:
  transformers-compat:
    five-three: true

apply-ghc-options: everything
ghc-options:
  "$everything": -split-sections -O0

# use custom ext-stg whole program compiler GHC
compiler:     ghc-8.11.0.20200527
ghc-variant:  ext-stg-whole-program-compiler

setup-info-locations: []
setup-info:
  ghc:
    linux64-custom-ext-stg-whole-program-compiler:
      8.11.0.20200527:
        url: "https://github.com/grin-compiler/ghc-wpc/releases/download/ghc-8.11.0.20200527-wpc/ghc-8.11.0.20200527.tar.xz"
