import Foundation
import Capacitor

@objc(cacheFilePlugin)
public class cacheFilePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "cacheFilePlugin"
    public let jsName = "cacheFile"
    
    private var activeCacheRequests = [String: String]()
    private let lock = NSLock()

    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "checkCache", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "downloadAndCache", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = cacheFile()

    @objc func checkCache(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url"), urlString.hasPrefix("https") else {
            call.resolve(["base64": call.getString("url") ?? ""])
            return
        }

        if let base64String = getBase64FromCache(urlString: urlString) {
            call.resolve(["base64": base64String])
        } else {
            call.resolve(["base64": NSNull()])
        }
    }

    @objc func downloadAndCache(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url"), urlString.hasPrefix("https"), let url = URL(string: urlString) else {
            call.resolve(["base64": call.getString("url") ?? ""])
            return
        }

        lock.lock()
        if let cachedBase64 = getBase64FromCache(urlString: urlString) {
            lock.unlock()
            call.resolve(["base64": cachedBase64])
            return
        }

        let downloadTask = URLSession.shared.dataTask(with: url) { data, response, error in
            self.lock.lock()
            defer { self.lock.unlock() }
            self.activeCacheRequests.removeValue(forKey: urlString)

            guard let data = data, error == nil else {
                call.reject("Failed to download file")
                return
            }

            if let base64String = self.saveToCacheAsBase64(urlString: urlString, data: data) {
                call.resolve(["base64": base64String])
            } else {
                call.reject("Failed to save file to cache")
            }
        }

        activeCacheRequests[urlString] = nil
        lock.unlock()

        downloadTask.resume()
    }

    private func saveToCacheAsBase64(urlString: String, data: Data) -> String? {
        let fileName = getFileNameForBase64(urlString: urlString)
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let base64FileURL = cacheDir?.appendingPathComponent(fileName)

        do {
            // Конвертируем данные в Base64 и сохраняем
            let base64String = data.base64EncodedString()
            try base64String.write(to: base64FileURL!, atomically: true, encoding: .utf8)
            let mimeType = getMimeType(for: URL(string: urlString)?.pathExtension ?? "")
            return "data:\(mimeType);base64,\(base64String)"
        } catch {
            print("Failed to save Base64 file to cache: \(error)")
            return nil
        }
    }

    private func getBase64FromCache(urlString: String) -> String? {
        let fileName = getFileNameForBase64(urlString: urlString)
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let base64FileURL = cacheDir?.appendingPathComponent(fileName)

        do {
            let base64String = try String(contentsOf: base64FileURL!, encoding: .utf8)
            let mimeType = getMimeType(for: URL(string: urlString)?.pathExtension ?? "")
            return "data:\(mimeType);base64,\(base64String)"
        } catch {
            return nil
        }
    }

    private func getFileNameForBase64(urlString: String) -> String {
        let url = URL(string: urlString)
        let fileExtension = url?.pathExtension ?? ""
        let hash = urlString.hashValue
        return "\(hash).\(fileExtension).base64"
    }

    private func getMimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "aac": return "audio/aac"
        case "abw": return "application/x-abiword"
        case "arc": return "application/x-freearc"
        case "avi": return "video/x-msvideo"
        case "azw": return "application/vnd.amazon.ebook"
        case "bin": return "application/octet-stream"
        case "bmp": return "image/bmp"
        case "bz": return "application/x-bzip"
        case "bz2": return "application/x-bzip2"
        case "csh": return "application/x-csh"
        case "css": return "text/css"
        case "csv": return "text/csv"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "eot": return "application/vnd.ms-fontobject"
        case "epub": return "application/epub+zip"
        case "gz": return "application/gzip"
        case "gif": return "image/gif"
        case "htm", "html": return "text/html"
        case "ico": return "image/vnd.microsoft.icon"
        case "ics": return "text/calendar"
        case "jar": return "application/java-archive"
        case "jpeg", "jpg": return "image/jpeg"
        case "js": return "text/javascript"
        case "json": return "application/json"
        case "jsonld": return "application/ld+json"
        case "mid", "midi": return "audio/midi"
        case "mjs": return "text/javascript"
        case "mp3": return "audio/mpeg"
        case "mp4": return "video/mp4"
        case "mpeg": return "video/mpeg"
        case "mpkg": return "application/vnd.apple.installer+xml"
        case "odp": return "application/vnd.oasis.opendocument.presentation"
        case "ods": return "application/vnd.oasis.opendocument.spreadsheet"
        case "odt": return "application/vnd.oasis.opendocument.text"
        case "oga": return "audio/ogg"
        case "ogv": return "video/ogg"
        case "ogx": return "application/ogg"
        case "opus": return "audio/opus"
        case "otf": return "font/otf"
        case "png": return "image/png"
        case "pdf": return "application/pdf"
        case "php": return "application/x-httpd-php"
        case "ppt": return "application/vnd.ms-powerpoint"
        case "pptx": return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "rar": return "application/vnd.rar"
        case "rtf": return "application/rtf"
        case "sh": return "application/x-sh"
        case "svg": return "image/svg+xml"
        case "swf": return "application/x-shockwave-flash"
        case "tar": return "application/x-tar"
        case "tif", "tiff": return "image/tiff"
        case "ts": return "video/mp2t"
        case "ttf": return "font/ttf"
        case "txt": return "text/plain"
        case "vsd": return "application/vnd.visio"
        case "wav": return "audio/wav"
        case "weba": return "audio/webm"
        case "webm": return "video/webm"
        case "webp": return "image/webp"
        case "woff": return "font/woff"
        case "woff2": return "font/woff2"
        case "xhtml": return "application/xhtml+xml"
        case "xls": return "application/vnd.ms-excel"
        case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "xml": return "application/xml"
        case "xul": return "application/vnd.mozilla.xul+xml"
        case "zip": return "application/zip"
        case "3gp": return "video/3gpp"
        case "3g2": return "video/3gpp2"
        case "7z": return "application/x-7z-compressed"
        default: return "application/octet-stream"
        }
    }
}
