#!/usr/bin/env bash
${IDRIS:-idris} $@ --quiet --port none --nocolor docs003.idr < input.in
rm *.ibc
