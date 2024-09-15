# capacitor-cache-file

A Capacitor plugin that enables caching of files of any type. It checks if a file is already cached and returns it if available; otherwise, it downloads the file, saves it to the cache, and returns the path to the saved file. The plugin also prevents duplication when the same URL is requested multiple times.

## For usage instructions, see:

- [How to Use (English)](https://antonseagull.com/post/caching-content-in-capacitorjs-applications-with-the-capacitor-cache-file-plugin)
- [Как использовать (Russian)](https://antonseagull.com/post/kak-kesirovat-faily-i-izobrazeniia-v-prilozeniiax-na-capacitorjs-s-ispolzovaniem-plagina-capacitor-cache-file)

## Install

```bash
npm install capacitor-cache-file
npx cap sync
```

## API

<docgen-index>

* [`checkCache(...)`](#checkcache)
* [`downloadAndCache(...)`](#downloadandcache)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### checkCache(...)

```typescript
checkCache(options: { url: string; }) => Promise<{ base64: string | null; }>
```

| Param         | Type                          |
| ------------- | ----------------------------- |
| **`options`** | <code>{ url: string; }</code> |

**Returns:** <code>Promise&lt;{ base64: string | null; }&gt;</code>

--------------------


### downloadAndCache(...)

```typescript
downloadAndCache(options: { url: string; }) => Promise<{ base64: string; }>
```

| Param         | Type                          |
| ------------- | ----------------------------- |
| **`options`** | <code>{ url: string; }</code> |

**Returns:** <code>Promise&lt;{ base64: string; }&gt;</code>

--------------------

</docgen-api>
