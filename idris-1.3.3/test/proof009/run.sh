#!/usr/bin/env bash
${IDRIS:-idris} $@ --consolewidth 70 --quiet --port none proof009.idr < input.in
rm -f *.ibc
