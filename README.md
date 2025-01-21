# F.R.E.Y.A. — Fast Rendering Engine for Yielding Adventures

## Dependencies

What you need to have to build the project:

- [Odin lang](https://odin-lang.org/)
- [GLFW3](https://www.glfw.org/)
- [OpenGL](https://www.opengl.org/)

## How to build

Before trying to build the project, make sure the submodules are cloned, either clone the repo with the following command:

````sh
git clone --recurse-submodules git@github.com:kosmios1/freya.git
```

or if you already have the repo cloned, run the following command:

```sh
git submodule update --init --recursive
```

After that, go to `freya/vendor/odin-imgui/` and run the following command:

```sh
python build.py
```

Use the build script from at the root of the repo.

```sh
./build.sh
````
