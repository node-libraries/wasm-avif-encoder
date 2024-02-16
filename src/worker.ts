/* eslint-disable no-unused-vars */
import { initWorker } from 'worker-lib';
import type { ModuleType } from './avif.js';

let encoderModule: ModuleType;
const getModule = async () => {
  const encoder = await import('./avif.js').then((m) => m.default);
  if (!encoderModule) {
    let module = await encoder().catch(() => null);
    if (!module) {
      module = await encoder();
      if (!module) throw new Error('module failed to load');
    }
    encoderModule = module;
  }
  return encoderModule;
};
const encode = async (
  data: BufferSource,
  width: number,
  height: number,
  quality: number
): Promise<Uint8Array | null> => {
  return (await getModule()).encode(data, width, height, quality);
};

// Initialization process to make it usable in Worker.
const map = initWorker({ encode });
// Export only the type
export type WorkerEncoder = typeof map;
