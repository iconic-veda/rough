setup:
    git submodule update --init --recursive
    cd freya/vendor/odin-imgui && python3 build.py

build-dbg:
    odin build animagik -out:build/animagik-dbg -debug -vet -strict-style -strict-target-features

run-dbg: build-dbg
    ./build/animagik-dbg

build:
    odin build animagik -out:build/animagik -vet -strict-style -strict-target-features

run: build
    ./build/animagik
