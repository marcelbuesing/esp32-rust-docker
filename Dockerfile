FROM alpine

RUN apk add --update ninja git python cmake curl rust g++ python2 make

#RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

ENV MY_BUILD_ROOT $HOME/.xtensa

RUN mkdir -p "$MY_BUILD_ROOT" && \
    cd "$MY_BUILD_ROOT" && \
    git clone https://github.com/espressif/llvm-xtensa.git && \
    git clone https://github.com/espressif/clang-xtensa.git llvm-xtensa/tools/clang && \
    mkdir llvm_build && \
    cd llvm_build && \
    cmake ../llvm-xtensa -DLLVM_TARGETS_TO_BUILD="Xtensa;X86" -DCMAKE_BUILD_TYPE=Release -G "Ninja" && \
    cmake --build .

RUN cd "$MY_BUILD_ROOT" && \
    git clone https://github.com/MabezDev/rust-xtensa.git && \
    cd rust-xtensa && \
    mkdir "$MY_BUILD_ROOT/rust_build" && \
    ./configure --llvm-root="$MY_BUILD_ROOT/llvm_build" --prefix="$MY_BUILD_ROOT/rust_build" && \
    python ./x.py --help && \
    python ./x.py build && \
    python ./x.py install && \
    "$MY_BUILD_ROOT/rust_build/bin/rustc" --print target-list | grep xtensa && \
    rustup toolchain link xtensa "$MY_BUILD_ROOT/rust_build" && \
    rustup run xtensa rustc --print target-list | grep xtensa
