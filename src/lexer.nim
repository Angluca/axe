import 
    strutils, 
    sets

type
  TokenKind* = enum
    tkComment, tkIdentifier, tkString, tkKeyword, tkSymbol, tkEof
    
  Token* = object
    kind*: TokenKind
    value*: string
    line*, col*: int

const Keywords = ["main", "void", "loop", "break"].toHashSet()

proc lex*(source: string): seq[Token] =
  var tokens: seq[Token]
  var i = 0
  var line = 1
  var col = 1
  
  while i < source.len:
    case source[i]
    of ' ', '\t': 
      inc i
      inc col
    of '\n':
      inc i
      inc line
      col = 1
    of '/':
      if i + 1 < source.len and source[i+1] == '/':
        var comment = "//"
        i += 2
        col += 2
        while i < source.len and source[i] != '\n':
          comment.add source[i]
          inc i
          inc col
        tokens.add Token(kind: tkComment, value: comment, line: line, col: col - comment.len)
      else:
        tokens.add Token(kind: tkSymbol, value: $source[i], line: line, col: col)
        inc i
        inc col
    of '"':
      var str = ""
      inc i
      inc col
      while i < source.len and source[i] != '"':
        str.add source[i]
        inc i
        inc col
      if i < source.len:
        inc i
        inc col
      tokens.add Token(kind: tkString, value: str, line: line, col: col - str.len - 1)
    else:
      if source[i].isAlphaAscii():
        var ident = ""
        let startCol = col
        while i < source.len and (source[i].isAlphaAscii() or source[i] == '_'):
          ident.add source[i]
          inc i
          inc col
        if ident in Keywords:
          tokens.add Token(kind: tkKeyword, value: ident, line: line, col: startCol)
        else:
          tokens.add Token(kind: tkIdentifier, value: ident, line: line, col: startCol)
      else:
        tokens.add Token(kind: tkSymbol, value: $source[i], line: line, col: col)
        inc i
        inc col
  
  tokens.add Token(kind: tkEof, value: "", line: line, col: col)
  return tokens
