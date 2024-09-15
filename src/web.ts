import { WebPlugin } from '@capacitor/core';
import type { cacheFilePlugin } from './definitions';

export class CacheFileWeb extends WebPlugin implements cacheFilePlugin {
  async checkCache(options: {
    url: string;
  }): Promise<{ base64: string | null }> {
    console.log('Web implementation: Checking cache for:', options.url);
    // Заглушка: возвращаем null, поскольку кэширование на вебе не реализовано
    return { base64: null };
  }

  async downloadAndCache(options: {
    url: string;
  }): Promise<{ base64: string }> {
    console.log(
      'Web implementation: Downloading and caching file from:',
      options.url,
    );
    // Заглушка: возвращаем исходный URL, поскольку кэширование на вебе не реализовано
    return { base64: options.url };
  }
}
