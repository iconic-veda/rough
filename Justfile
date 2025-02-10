setup:
    git submodule update --init --recursive
    cd freya/vendor/odin-imgui && python3 build.py
    mkdir build/

build-dbg:
    # odin build animagik -out:build/animagik-dbg -debug
    odin build animagik -out:build/animagik-dbg -debug -extra-linker-flags:"-Lbuild/libs -Wl,-rpath=build/libs"

run-dbg: build-dbg
    ./build/animagik-dbg

build:
    odin build animagik -out:build/animagik

run: build
    ./build/animagik
