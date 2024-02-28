#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>
#include <avif/avif.h>

using namespace emscripten;

EM_JS(void, js_console_log, (const char *str), {
  console.log(UTF8ToString(str));
});

val encode(std::string img_in, int width, int height, float quality)
{
  avifImage *image = avifImageCreate(width, height, 8, AVIF_PIXEL_FORMAT_YUV444);

  avifRGBImage rgb;
  avifRGBImageSetDefaults(&rgb, image);
  rgb.depth = 8;
  rgb.format = AVIF_RGB_FORMAT_RGBA;
  rgb.pixels = (uint8_t *)img_in.c_str();
  rgb.rowBytes = width * 4;

  if (avifImageRGBToYUV(image, &rgb) != AVIF_RESULT_OK)
  {
    return val::null();
  }
  avifEncoder *encoder = avifEncoderCreate();
  encoder->quality = (int)((quality) / 100 * 63);
  encoder->speed = 6;

  avifRWData raw = AVIF_DATA_EMPTY;

  avifResult encodeResult = avifEncoderWrite(encoder, image, &raw);
  avifEncoderDestroy(encoder);
  avifImageDestroy(image);
  if (encodeResult != AVIF_RESULT_OK)
  {
    return val::null();
  }
  val result = val::global("Uint8Array").new_(typed_memory_view(raw.size, raw.data));
  avifRWDataFree(&raw);
  return result;
}

EMSCRIPTEN_BINDINGS(my_module)
{
  function("encode", &encode);
}
