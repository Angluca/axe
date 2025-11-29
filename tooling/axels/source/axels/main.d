module axels.main;

import std.stdio;
import std.json;
import std.string;
import std.conv;
import std.exception;
import std.process;
import std.file;
import std.algorithm;

struct LspRequest {
    string jsonrpc;
    string method;
    JSONValue id;
    JSONValue params;
}

struct Diagnostic {
    string message;
    string fileName;
    size_t line;  
    size_t column;
}

__gshared string[string] g_openDocs;

string uriToPath(string uri) {
    enum prefix = "file://";
    if (uri.startsWith(prefix)) {
        return uri[prefix.length .. $];
    }
    return uri;
}

string wordChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_";

string extractWordAt(string text, size_t line0, size_t char0) {
    auto lines = text.splitLines();
    if (line0 >= lines.length) {
        return "";
    }
    auto line = lines[line0];
    if (char0 >= line.length) {
        if (line.length == 0) return "";
        char0 = cast(int)line.length - 1;
    }

    size_t start = char0;
    while (start > 0 && wordChars.canFind(line[start - 1])) {
        --start;
    }
    size_t end = char0;
    while (end < line.length && wordChars.canFind(line[end])) {
        ++end;
    }
    return line[start .. end];
}

Diagnostic[] parseDiagnostics(string text) {
    Diagnostic[] result;
    foreach (line; text.splitLines()) {
        auto trimmed = line.strip();
        if (trimmed.length == 0) {
            continue;
        }

        auto first = trimmed.countUntil(':');
        if (first <= 0) {
            continue;
        }
        auto second = trimmed.countUntil(':', first + 1);
        if (second <= 0) {
            continue;
        }
        auto third = trimmed.countUntil(':', second + 1);
        if (third <= 0) {
            continue;
        }

        string fileName = trimmed[0 .. first];
        string lineStr  = trimmed[first + 1 .. second];
        string colStr   = trimmed[second + 1 .. third];
        string msg      = trimmed[third + 1 .. $].strip();

        size_t ln, col;
        try {
            ln  = to!size_t(lineStr.strip());
            col = to!size_t(colStr.strip());
        } catch (Exception) {
            continue;
        }

        Diagnostic d;
        d.fileName = fileName;
        d.line = ln;
        d.column = col;
        d.message = msg;
        result ~= d;
    }
    return result;
}

Diagnostic[] runCompilerOn(string uri, string text) {
    string path = uriToPath(uri);
    try {
        std.file.write(path, text);
    } catch (Exception) {
        return Diagnostic[].init;
    }

    Diagnostic[] diags;
    try {
        auto result = execute(["axc", path]);
        diags ~= parseDiagnostics(result.output);
    } catch (Exception) {
    }
    return diags;
}

void sendDiagnostics(string uri, Diagnostic[] diags) {
    JSONValue root = JSONValue(JSONType.object);
    root["jsonrpc"] = "2.0";
    root["method"]  = "textDocument/publishDiagnostics";

    JSONValue params = JSONValue(JSONType.object);
    params["uri"] = uri;

    JSONValue arr = JSONValue(JSONType.array);
    foreach (d; diags) {
        JSONValue jd   = JSONValue(JSONType.object);
        JSONValue rng  = JSONValue(JSONType.object);
        JSONValue sPos = JSONValue(JSONType.object);
        JSONValue ePos = JSONValue(JSONType.object);

        long l  = cast(long)(d.line > 0 ? d.line - 1 : 0);
        long ch = cast(long)(d.column > 0 ? d.column - 1 : 0);

        sPos["line"]      = l;
        sPos["character"] = ch;
        ePos["line"]      = l;
        ePos["character"] = ch + 1;

        rng["start"] = sPos;
        rng["end"]   = ePos;

        jd["range"]   = rng;
        jd["message"] = d.message;
        jd["severity"] = 1L;

        arr.array ~= jd;
    }

    params["diagnostics"] = arr;
    root["params"] = params;

    writeMessage(root.toString());
}

string readMessage() {
    size_t contentLength;

    while (true) {
        if (stdin.eof) {
            return null;
        }
        string line = stdin.readln();
        line = line.stripRight("\r\n");
        if (line.length == 0) {
            break;
        }
        auto lower = line.toLower();
        enum prefix = "content-length:";
        if (lower.startsWith(prefix)) {
            auto value = line[prefix.length .. $].strip();
            contentLength = to!size_t(value);
        }
    }

    if (contentLength == 0) {
        return null;
    }

    ubyte[] buf;
    buf.length = contentLength;
    size_t readBytes = 0;
    while (readBytes < contentLength) {
        auto chunk = stdin.rawRead(buf[readBytes .. $]);
        auto n = chunk.length;
        if (n == 0) break;
        readBytes += n;
    }

    return cast(string) buf[0 .. readBytes];
}

void writeMessage(string payload) {
    auto bytes = cast(const(ubyte)[]) payload;
    stdout.writef("Content-Length: %s\r\n\r\n", bytes.length);
    stdout.write(bytes);
    stdout.flush();
}

LspRequest parseRequest(string body) {
    auto j = parseJSON(body);
    LspRequest req;
    if (j.type == JSONType.object) {
        auto obj = j.object;
        if ("jsonrpc" in obj) req.jsonrpc = obj["jsonrpc"].str;
        if ("method" in obj)  req.method  = obj["method"].str;
        if ("id" in obj)      req.id      = obj["id"];
        if ("params" in obj)  req.params  = obj["params"];
    }
    return req;
}

void sendResponse(JSONValue id, JSONValue result) {
    JSONValue root = JSONValue(JSONType.object);
    root["jsonrpc"] = "2.0";
    root["id"]      = id;
    root["result"]  = result;
    writeMessage(root.toString());
}

void sendError(JSONValue id, int code, string message) {
    JSONValue root = JSONValue(JSONType.object);
    root["jsonrpc"] = "2.0";
    root["id"]      = id;

    JSONValue err = JSONValue(JSONType.object);
    err["code"]    = code;
    err["message"] = message;
    root["error"]  = err;

    writeMessage(root.toString());
}

void handleInitialize(LspRequest req) {
    JSONValue capabilities = JSONValue(JSONType.object);
    JSONValue hoverProvider = JSONValue(true);
    capabilities["hoverProvider"] = hoverProvider;

    JSONValue completionProvider = JSONValue(JSONType.object);
    JSONValue triggerChars = JSONValue(JSONType.array);
    triggerChars.array ~= JSONValue(".");
    completionProvider["triggerCharacters"] = triggerChars;
    capabilities["completionProvider"] = completionProvider;

    JSONValue result = JSONValue(JSONType.object);
    result["capabilities"] = capabilities;

    sendResponse(req.id, result);
}

void handleInitialized(LspRequest req) {
}

void handleShutdown(LspRequest req) {
    JSONValue nilResult;
    sendResponse(req.id, nilResult);
}

void handleExit(LspRequest req) {
    import core.stdc.stdlib : exit;
    exit(0);
}

void handleDidOpen(LspRequest req) {
    auto params = req.params;
    if (params.type != JSONType.object) {
        return;
    }

    auto pObj = params.object;
    if (!("textDocument" in pObj)) {
        return;
    }

    auto td = pObj["textDocument"];
    if (td.type != JSONType.object) {
        return;
    }

    auto tdObj = td.object;
    if (!("uri" in tdObj) || !("text" in tdObj)) {
        return;
    }

    string uri  = tdObj["uri"].str;
    string text = tdObj["text"].str;

    g_openDocs[uri] = text;

    auto diags = runCompilerOn(uri, text);
    sendDiagnostics(uri, diags);
}

void handleHover(LspRequest req) {
    auto params = req.params;
    if (params.type != JSONType.object) {
        return;
    }

    auto pObj = params.object;
    if (!("textDocument" in pObj) || !("position" in pObj)) {
        return;
    }

    auto td = pObj["textDocument"].object;
    string uri = td["uri"].str;

    auto pos = pObj["position"].object;
    size_t line0   = cast(size_t) pos["line"].integer;
    size_t char0   = cast(size_t) pos["character"].integer;

    auto it = uri in g_openDocs;
    if (it is null) {
        JSONValue empty;
        sendResponse(req.id, empty);
        return;
    }

    string text = *it;
    string word = extractWordAt(text, line0, char0);
    if (word.length == 0) {
        JSONValue empty;
        sendResponse(req.id, empty);
        return;
    }

    JSONValue contents = JSONValue(JSONType.object);
    contents["kind"]  = "plaintext";
    contents["value"] = "" ~ word;

    JSONValue result = JSONValue(JSONType.object);
    result["contents"] = contents;

    sendResponse(req.id, result);
}

void handleCompletion(LspRequest req) {
    auto params = req.params;
    if (params.type != JSONType.object) {
        return;
    }

    auto pObj = params.object;
    if (!("textDocument" in pObj) || !("position" in pObj)) {
        return;
    }

    auto td = pObj["textDocument"].object;
    string uri = td["uri"].str;

    auto pos = pObj["position"].object;
    size_t line0   = cast(size_t) pos["line"].integer;
    size_t char0   = cast(size_t) pos["character"].integer;

    auto it = uri in g_openDocs;
    if (it is null) {
        JSONValue empty;
        sendResponse(req.id, empty);
        return;
    }

    string text = *it;
    string prefix = extractWordAt(text, line0, char0);

    string[] keywords = [
        "def", "pub", "mut", "val", "loop", "for", "in", "if", "else",
        "elif", "switch", "case", "break", "continue", "model", "enum",
        "use", "test", "assert", "unsafe", "parallel", "single", "platform"
    ];

    JSONValue items = JSONValue(JSONType.array);

    foreach (k; keywords) {
        if (prefix.length == 0 || k.startsWith(prefix)) {
            JSONValue item = JSONValue(JSONType.object);
            item["label"] = k;
            item["kind"]  = 14L; // Keyword
            items.array ~= item;
        }
    }

    foreach (ln; text.splitLines()) {
        string current;
        foreach (ch; ln) {
            if (wordChars.canFind(ch)) {
                current ~= ch;
            } else {
                if (current.length > 0 && (prefix.length == 0 || current.startsWith(prefix))) {
                    JSONValue item = JSONValue(JSONType.object);
                    item["label"] = current;
                    item["kind"]  = 6L;
                    items.array ~= item;
                }
                current = "";
            }
        }
        if (current.length > 0 && (prefix.length == 0 || current.startsWith(prefix))) {
            JSONValue item = JSONValue(JSONType.object);
            item["label"] = current;
            item["kind"]  = 6L;
            items.array ~= item;
        }
    }

    JSONValue result = JSONValue(JSONType.object);
    result["isIncomplete"] = false;
    result["items"]        = items;

    sendResponse(req.id, result);
}

void dispatch(LspRequest req) {
    switch (req.method) {
    case "initialize":
        handleInitialize(req);
        break;
    case "initialized":
        handleInitialized(req);
        break;
    case "shutdown":
        handleShutdown(req);
        break;
    case "exit":
        handleExit(req);
        break;
    case "textDocument/didOpen":
        handleDidOpen(req);
        break;
    case "textDocument/hover":
        handleHover(req);
        break;
    case "textDocument/completion":
        handleCompletion(req);
        break;
    default:
        if (req.id.type != JSONType.null_) {
            sendError(req.id, -32_601, "Method not found");
        }
        break;
    }
}

int main() {
    while (true) {
        auto body = readMessage();
        if (body is null) {
            break;
        }
        try {
            auto req = parseRequest(body);
            if (req.method.length == 0) {
                continue;
            }
            dispatch(req);
        } catch (Exception e) {
        }
    }
    return 0;
}
