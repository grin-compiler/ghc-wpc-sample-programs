#!/usr/bin/env bash
${IDRIS:-idris} $@ --nobanner --nocolor --port none < input.in
