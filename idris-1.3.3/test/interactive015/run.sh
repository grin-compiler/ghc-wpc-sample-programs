#!/usr/bin/env bash

cp src/interactive015.idr .
${IDRIS:-idris} "$@" --quiet --port none interactive015.idr < input.in

cat interactive015.idr

rm -f *.ibc interactive015.idr
