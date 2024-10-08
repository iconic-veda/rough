#!/bin/sh

odin build freya -out:build/freya -debug -build-mode:shared -vet -strict-style -strict-target-features
odin run sandbox -out:build/sandbox -debug -vet -strict-style -strict-target-features
