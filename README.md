# @node-libraries/wasm-avif-encoder

# Overview

Provides the ability to encode WebP using WebAssembly and WebWorker.

Remix(esbuild) and Next.js(webpack) are supported.

# types

```ts
encode(params:{data: BufferSource, width: number, height: number, quality?: number}): Promise<Uint8Array | null>
```

```ts
encode(params:{data: ImageData, quality?: number}): Promise<Uint8Array | null>
```

# usage

```ts
import { encode } from '@node-libraries/wasm-avif-encoder';

// Next.js(webpack)
const encodedValue = await encode({ data: ctx.getImageData(0, 0, img.width, img.height) });
const encodedValue2 = await encode({ data: arrayBuffer, width, height });

// Remix(esbuild)
// Files need to be installed manually
// node_modules/@node-libraries/wasm-webp-encoder/dist  =>
//   public/avif/worker.js
//   public/avif/avif.js
//   public/avif/avif.wasm
const encodedValue3 = await encode({ data: arrayBuffer, width, height, worker: '/avif/worker.js' });
```

# Sample when used with Next.js

- https://github.com/SoraKumo001/next-webp
