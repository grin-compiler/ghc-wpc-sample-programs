# Sample programs for GHC whole program compiler

This repo uses a custom GHC (ghc-wpc). Stack will download it and set up automatically.

To compile the `simple-app` program run the following command:
```
stack --stack-root `pwd`/.stack-root build
```

To compile a given sample program (agda, idris, pandoc, or all of them) rename `stack.yaml.PROGRAM_NAME` to `stack.yaml` then run the command above.

It could take 60 minutes to compile all together, so start with the fastest first (27 sec) the `simple-app`.

When stack build finished, go to `simple-app/.stack-work/dist/x86_64-linux-custom-ext-stg-whole-program-compiler/Cabal-3.2.0.0/build/simple-app`

and execute:  
`gen-exe` *simple-app.ghc_stgapp*

It generates `a.out` executable via the whole program stg compiler pipeline.
