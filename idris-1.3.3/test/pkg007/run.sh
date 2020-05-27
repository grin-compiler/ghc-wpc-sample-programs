#!/usr/bin/env bash
cd toy
${IDRIS:-idris} $@ --build toy.ipkg --ibcsubdir ../ibcout
cd ../ibcout
${IDRIS:-idris} $@ --quiet < ../input.in
cd ..
rm -rf ibcout
