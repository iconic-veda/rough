#!/bin/sh

# odin build freya -out:build/freya -debug -build-mode:shared -vet -strict-style -strict-target-features

odin run animagik -out:build/gui -debug -vet -strict-style -strict-target-features
