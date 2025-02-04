#!/bin/sh

# odin build freya -out:build/freya -debug -build-mode:shared -vet -strict-style -strict-target-features

odin build animagik -out:build/animagik-dbg -debug -vet -strict-style -strict-target-features && ./build/animagik-dbg
