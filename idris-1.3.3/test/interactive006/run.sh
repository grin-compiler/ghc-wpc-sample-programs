#!/usr/bin/env bash
${IDRIS:-idris} $@ --quiet --port none --port 5000 interactive006.idr < input.in
rm -f *.ibc
