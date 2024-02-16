import { createWorker } from 'worker-lib';
import type { WorkerEncoder } from './worker.js';

const execute: Record<string, ReturnType<typeof createWorker>> = {};

const createExecuter = (worker?: string) => {
  const key = worker ?? './worker.js';
  if (!execute[key]) {
    execute[key] = createWorker<WorkerEncoder>(
      () =>
        worker
          ? new Worker(new URL(worker, import.meta.url))
          : new Worker(new URL('./worker.js', import.meta.url)),
      4
    );
  }
  return execute[key];
};

export const encode: {
  (
    params:
      | {
          data: BufferSource;
          width: number;
          height: number;
          quality?: number;
          worker?: string;
        }
      | {
          data: ImageData;
          width?: number;
          height?: number;
          quality?: number;
          worker?: string;
        }
  ): Promise<Uint8Array | null>;
} = async ({ data, width, height, quality, worker }) => {
  const execute = createExecuter(worker);
  return data instanceof ImageData
    ? execute('encode', data.data, data.width, data.height, quality || 100)
    : execute('encode', data, width as number, height as number, quality || 100);
};

export default true;
