# Sample programs for GHC whole program compiler

This repo uses a custom GHC (ghc-wpc). Stack will download it and set up automatically. **(only on x64 Ubuntu 16.04-17.10)**

## Preparation

To compile the sample executables, you will need the *whole stg program compiler*.  
Go to https://github.com/grin-compiler/ghc-whole-program-compiler-project and follow the **user** install steps.

## Sample programs

| Sample | project file|
| --- | --- |
| simple app | `stack.yaml.simple` |
| agda | `stack.yaml.agda` |
| idris | `stack.yaml.idris` |
| pandoc | `stack.yaml.pandoc` |

## Build the sample programs

By default the `stack.yaml` file is the same as `stack.yaml.simple`.  
To compile the `simple-app` program run the following command:
```
stack --stack-root `pwd`/.stack-root build
```
It will use GHC-WPC to build the project that is specified in the `stack.yaml`.  
When the compilation process finishes, GHC-WPC will leave the program's Ext-STG IR (`.o_stgbin`) and the the application's linker metadata (`.ghc_stgapp`) on the disk beside the executable generated by GHC's standard pipeline.  

Now go to `simple-app/.stack-work/dist/x86_64-linux-custom-ext-stg-whole-program-compiler/Cabal-3.2.0.0/build/simple-app`  
and execute:
```
gen-exe simple-app.ghc_stgapp
```
to generate the executabe with the *whole stg program compiler*.
It will generate `a.out`.

## Select the sample application to compile

By default the `stack.yaml` is set to the samallest sample program **simple-app** (`stack.yaml.simple`).

To compile another sample program (agda, idris, pandoc, or all of them), rename `stack.yaml.PROGRAM_NAME` to `stack.yaml` then run the command above.

It could take 60 minutes to compile all together, so start with the fastest first (27 sec) the **simple-app**.
