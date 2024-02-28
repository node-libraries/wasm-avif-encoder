SHELL=/bin/bash
WORKDIR=work
DISTDIR=dist
ESMDIR=$(DISTDIR)
WORKERSDIR=$(DISTDIR)/workers
LIBDIR=libavif/ext

TARGET_ESM_BASE = $(notdir $(basename src/avif.cpp))
TARGET_ESM = $(ESMDIR)/$(TARGET_ESM_BASE).js

CFLAGS = -O3 -msimd128 \
        -Ilibwebp -Ilibwebp/src -Ilibavif/include -Ilibavif/third_party/libyuv/include -Ilibavif/ext/aom \
        -DAVIF_CODEC_AOM_ENCODE -DAVIF_LOCAL_AOM -DAVIF_CODEC_AOM

CFLAGS_ASM = --bind \
             -s WASM=1 -s ALLOW_MEMORY_GROWTH=1 -s ENVIRONMENT=web -s DYNAMIC_EXECUTION=0 -s MODULARIZE=1 \
             -s STACK_SIZE=5MB \

AVIF_SOURCES := libavif/src/alpha.c \
                libavif/src/avif.c \
                libavif/src/colr.c \
                libavif/src/colrconvert.c \
                libavif/src/diag.c \
                libavif/src/exif.c \
                libavif/src/io.c \
                libavif/src/mem.c \
                libavif/src/obu.c \
                libavif/src/rawdata.c \
                libavif/src/read.c \
                libavif/src/reformat.c \
                libavif/src/reformat_libsharpyuv.c \
                libavif/src/reformat_libyuv.c \
                libavif/src/scale.c \
                libavif/src/stream.c \
                libavif/src/utils.c \
                libavif/src/write.c \
                libavif/src/codec_aom.c \
                libavif/third_party/libyuv/source/scale.c \
                libavif/third_party/libyuv/source/scale_common.c \
                libavif/third_party/libyuv/source/scale_any.c \
                libavif/third_party/libyuv/source/row_common.c \
                libavif/third_party/libyuv/source/planar_functions.c


AVIF_OBJECTS := $(AVIF_SOURCES:.c=.o)

.PHONY: all esm workers clean

all: esm 

$(AVIF_OBJECTS): %.o: %.c | $(LIBDIR)/aom_build/libaom.a
	@emcc $(CFLAGS) -c $< -o $@

$(LIBDIR)/aom_build/libaom.a:
	@echo Building aom...
	@cd $(LIBDIR) && ./aom.cmd && mkdir aom_build && cd aom_build && \
	emcmake cmake ../aom \
    -DENABLE_CCACHE=1 \
    -DAOM_TARGET_CPU=generic \
    -DENABLE_DOCS=0 \
    -DENABLE_TESTS=0 \
    -DCONFIG_ACCOUNTING=1 \
    -DCONFIG_INSPECTION=1 \
    -DCONFIG_MULTITHREAD=0 \
    -DCONFIG_RUNTIME_CPU_DETECT=0 \
    -DCONFIG_WEBM_IO=0 \
    -DCMAKE_BUILD_TYPE=Release && \
	make aom

$(WORKDIR):
	@mkdir -p $(WORKDIR)

$(WORKDIR)/avif.a: $(WORKDIR) $(AVIF_OBJECTS)
	@emar rcs $@ $(AVIF_OBJECTS)

esm: $(TARGET_ESM)

${TARGET_ESM}: src/avif.cpp $(WORKDIR)/avif.a $(LIBDIR)/aom_build/libaom.a
	emcc $(CFLAGS) -o $@ $^ \
       $(CFLAGS_ASM) -s EXPORT_ES6=1

clean:
	@echo Cleaning up...
	@rm -rf $(WORKDIR) $(LIBDIR)/aom_build $(DISTDIR)/esm $(DISTDIR)/workers
