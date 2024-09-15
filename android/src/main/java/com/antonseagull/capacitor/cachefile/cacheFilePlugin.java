package com.antonseagull.capacitor.cachefile;


import android.content.Context;
import android.util.Base64;
import com.getcapacitor.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Future;

@CapacitorPlugin(name = "cacheFile")
public class cacheFilePlugin extends Plugin {

    private cacheFile implementation = new cacheFile();

    private final ConcurrentHashMap<String, String> activeCacheRequests = new ConcurrentHashMap<>();

    @PluginMethod
    public void checkCache(PluginCall call) {
        String urlString = call.getString("url");

        if (urlString == null || !urlString.startsWith("https")) {
            call.resolve(new JSObject().put("base64", urlString));
            return;
        }

        String base64String = getBase64FromCache(urlString);
        if (base64String != null) {
            call.resolve(new JSObject().put("base64", base64String));
        } else {
            call.resolve(new JSObject().put("base64", JSObject.NULL));
        }
    }

    @PluginMethod
    public void downloadAndCache(PluginCall call) {
        String urlString = call.getString("url");

        if (urlString == null || !urlString.startsWith("https")) {
            call.resolve(new JSObject().put("base64", urlString));
            return;
        }

        if (activeCacheRequests.containsKey(urlString)) {
            String cachedBase64 = getBase64FromCache(urlString);
            if (cachedBase64 != null) {
                call.resolve(new JSObject().put("base64", cachedBase64));
            }
            return;
        }

        new Thread(() -> {
            try {
                java.net.URL url = new java.net.URL(urlString);
                java.net.HttpURLConnection connection = (java.net.HttpURLConnection) url.openConnection();
                connection.connect();

                if (connection.getResponseCode() != java.net.HttpURLConnection.HTTP_OK) {
                    call.reject("Failed to download file");
                    return;
                }

                File cacheFile = saveToCacheAsBase64(urlString, connection.getInputStream());
                if (cacheFile != null) {
                    String base64String = getBase64FromCache(urlString);
                    call.resolve(new JSObject().put("base64", base64String));
                } else {
                    call.reject("Failed to save file to cache");
                }

                connection.disconnect();
            } catch (Exception e) {
                call.reject("Failed to download file: " + e.getMessage());
            }
        }).start();
    }

    private File saveToCacheAsBase64(String urlString, java.io.InputStream inputStream) {
        try {
            File cacheDir = getContext().getCacheDir();
            String fileName = getFileNameForBase64(urlString);
            File base64File = new File(cacheDir, fileName);

            byte[] buffer = new byte[1024];
            int bytesRead;
            java.io.ByteArrayOutputStream outputStream = new java.io.ByteArrayOutputStream();

            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }

            String base64String = Base64.encodeToString(outputStream.toByteArray(), Base64.NO_WRAP);
            outputStream.close();

            FileOutputStream fos = new FileOutputStream(base64File);
            fos.write(base64String.getBytes());
            fos.close();

            return base64File;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    private String getBase64FromCache(String urlString) {
        try {
            File cacheDir = getContext().getCacheDir();
            String fileName = getFileNameForBase64(urlString);
            File base64File = new File(cacheDir, fileName);

            if (!base64File.exists()) {
                return null;
            }

            FileInputStream fis = new FileInputStream(base64File);
            byte[] data = new byte[(int) base64File.length()];
            fis.read(data);
            fis.close();

            String base64String = new String(data);
            String mimeType = getMimeType(getFileExtension(urlString));
            return "data:" + mimeType + ";base64," + base64String;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    private String getFileNameForBase64(String urlString) {
        String fileExtension = getFileExtension(urlString);
        int hash = urlString.hashCode();
        return hash + "." + fileExtension + ".base64";
    }

    private String getFileExtension(String urlString) {
        return urlString.substring(urlString.lastIndexOf('.') + 1);
    }

    private String getMimeType(String fileExtension) {
        switch (fileExtension.toLowerCase()) {
            case "aac": return "audio/aac";
            case "abw": return "application/x-abiword";
            case "arc": return "application/x-freearc";
            case "avi": return "video/x-msvideo";
            case "azw": return "application/vnd.amazon.ebook";
            case "bin": return "application/octet-stream";
            case "bmp": return "image/bmp";
            case "bz": return "application/x-bzip";
            case "bz2": return "application/x-bzip2";
            case "csh": return "application/x-csh";
            case "css": return "text/css";
            case "csv": return "text/csv";
            case "doc": return "application/msword";
            case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case "eot": return "application/vnd.ms-fontobject";
            case "epub": return "application/epub+zip";
            case "gz": return "application/gzip";
            case "gif": return "image/gif";
            case "htm":
            case "html": return "text/html";
            case "ico": return "image/vnd.microsoft.icon";
            case "ics": return "text/calendar";
            case "jar": return "application/java-archive";
            case "jpeg":
            case "jpg": return "image/jpeg";
            case "js": return "text/javascript";
            case "json": return "application/json";
            case "jsonld": return "application/ld+json";
            case "mid":
            case "midi": return "audio/midi";
            case "mjs": return "text/javascript";
            case "mp3": return "audio/mpeg";
            case "mp4": return "video/mp4";
            case "mpeg": return "video/mpeg";
            case "mpkg": return "application/vnd.apple.installer+xml";
            case "odp": return "application/vnd.oasis.opendocument.presentation";
            case "ods": return "application/vnd.oasis.opendocument.spreadsheet";
            case "odt": return "application/vnd.oasis.opendocument.text";
            case "oga": return "audio/ogg";
            case "ogv": return "video/ogg";
            case "ogx": return "application/ogg";
            case "opus": return "audio/opus";
            case "otf": return "font/otf";
            case "png": return "image/png";
            case "pdf": return "application/pdf";
            case "php": return "application/x-httpd-php";
            case "ppt": return "application/vnd.ms-powerpoint";
            case "pptx": return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
            case "rar": return "application/vnd.rar";
            case "rtf": return "application/rtf";
            case "sh": return "application/x-sh";
            case "svg": return "image/svg+xml";
            case "swf": return "application/x-shockwave-flash";
            case "tar": return "application/x-tar";
            case "tif":
            case "tiff": return "image/tiff";
            case "ts": return "video/mp2t";
            case "ttf": return "font/ttf";
            case "txt": return "text/plain";
            case "vsd": return "application/vnd.visio";
            case "wav": return "audio/wav";
            case "weba": return "audio/webm";
            case "webm": return "video/webm";
            case "webp": return "image/webp";
            case "woff": return "font/woff";
            case "woff2": return "font/woff2";
            case "xhtml": return "application/xhtml+xml";
            case "xls": return "application/vnd.ms-excel";
            case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            case "xml": return "application/xml";
            case "xul": return "application/vnd.mozilla.xul+xml";
            case "zip": return "application/zip";
            case "3gp": return "video/3gpp";
            case "3g2": return "video/3gpp2";
            case "7z": return "application/x-7z-compressed";
            default: return "application/octet-stream";
        }
    }
}

