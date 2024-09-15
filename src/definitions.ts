export interface cacheFilePlugin {
  checkCache(options: { url: string }): Promise<{ base64: string | null }>;
  downloadAndCache(options: { url: string }): Promise<{ base64: string }>;
}
