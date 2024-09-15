import { registerPlugin } from '@capacitor/core';

import type { cacheFilePlugin } from './definitions';

const cacheFile = registerPlugin<cacheFilePlugin>('cacheFile', {
  web: () => import('./web').then(m => new m.CacheFileWeb()),
});

export * from './definitions';
export { cacheFile };
