#!/usr/bin/env bash
${IDRIS:-idris} $@ --quiet --port none --nobanner --nocolor  < input.in
