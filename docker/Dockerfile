FROM emscripten/emsdk
WORKDIR /app
RUN  apt-get update && apt-get install -y dh-autoreconf && \
    git clone https://github.com/AOMediaCodec/libavif &&\
    ln -s /app/libavif/include/avif /emsdk/upstream/lib/clang/19/include/avif
