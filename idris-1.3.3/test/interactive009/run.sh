#!/usr/bin/env bash
${IDRIS:-idris} $@ --quiet --port none interactive009.idr < input.in
rm -f *.ibc
