My playground for WebAssembly text format!

# How did I build this WebAssembly Application?

I used the WebAssembly Binary Toolkit. In order to install the toolkit, you need to follow these steps (if you are running MacOS):

1. Install CMake 
  ```brew install cmake```
2. Install the WebAssembly Binary Toolkit (aka wabt)
  ```bash
  $ git clone --recursive https://github.com/WebAssembly/wabt
  $ cd wabt
  $ mkdir build
  $ $ cd build
  $ cmake ..
  $ cmake --build .
  ```
3. Put those installed binaries in your PATH. I use Fish shell, so I run the following command:
```$ set fish_user_paths $fish_user_paths PATH_TO_WHERE_YOU_INSTALLED_WABT/bin```

Now, you can run the tools in the toolkit. For example, to compile a WebAssembly Text Format file to a WebAssembly binary, we can do:

```wat2wasm example.wat -o example.wasm```

