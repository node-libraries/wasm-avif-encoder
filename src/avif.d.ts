export declare type ModuleType = {
  encode: (data: BufferSource, width: number, height: number, quality: number) => Uint8Array | null;
};
declare const encoder: (options?: {
  instantiateWasm?: (
    imports?: WebAssembly.Imports,
    receiver: (instance: WebAssembly.WebAssemblyInstantiatedSource) => Promise<unknown>
  ) => void;
  locateFile?: (path: string, scriptDirectory: string) => string;
  wasmBinary?: ArrayBuffer;
}) => Promise<ModuleType>;

export default encoder;
