#!/usr/bin/env bash
${IDRIS:-idris} $@ --quiet --port none --nocolor docs004.idr < input.in
rm *.ibc
