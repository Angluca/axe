import 
    lexer, 
    ast

type
  Parser = object
    tokens: seq[Token]
    pos: int
    current: Token

proc initParser*(tokens: seq[Token]): Parser =
  result.tokens = tokens
  result.pos = 0
  result.current = if tokens.len > 0: tokens[0] else: Token(kind: tkEof, value: "", line: 0, col: 0)

proc advance(p: var Parser) =
  if p.pos < p.tokens.len - 1:
    inc p.pos
    p.current = p.tokens[p.pos]
  else:
    p.current = Token(kind: tkEof, value: "", line: 0, col: 0)

proc expect(p: var Parser, kind: TokenKind) =
  if p.current.kind != kind:
    raise newException(ValueError, "Expected " & $kind & " but got " & $p.current.kind)
  p.advance()

proc parseFuncDecl(p: var Parser): Node =
  # Handle function name and return type
  p.expect(tkIdentifier)
  result = Node(kind: nkFuncDecl)
  result.name = p.current.value
  p.advance()
  
  # Skip return type annotation
  if p.current.kind == tkSymbol and p.current.value == ":":
    p.advance()
    while p.current.kind != tkSymbol or p.current.value != "(":
      p.advance()
  
  # Parse parameters
  p.expect(tkSymbol) # (
  result.params = @[]
  while p.current.kind != tkSymbol or p.current.value != ")":
    if p.current.kind == tkIdentifier:
      result.params.add(p.current.value)
      p.advance()
    if p.current.kind == tkSymbol and p.current.value == ",":
      p.advance()
  p.expect(tkSymbol) # )
  
  # Parse body
  p.expect(tkSymbol) # {
  result.body = @[]
  while p.current.kind != tkSymbol or p.current.value != "}":
    case p.current.kind
    of tkKeyword:
      if p.current.value == "break":
        result.body.add(Node(kind: nkBreak))
        p.advance()
      elif p.current.value == "loop":
        p.advance()
        var loopNode = Node(kind: nkLoop, loopBody: @[])
        p.expect(tkSymbol) # {
        while p.current.kind != tkSymbol or p.current.value != "}":
          # Parse loop body statements
          if p.current.kind == tkIdentifier and p.current.value == "println":
            p.advance()
            p.expect(tkSymbol) # (
            var call = Node(kind: nkCall, fnName: "println", args: @[])
            if p.current.kind == tkString:
              call.args.add(Node(kind: nkStrLit, value: p.current.value))
              p.advance()
            p.expect(tkSymbol) # )
            loopNode.loopBody.add(call)
          elif p.current.kind == tkKeyword and p.current.value == "break":
            loopNode.loopBody.add(Node(kind: nkBreak))
            p.advance()
          else:
            p.advance()
        p.expect(tkSymbol) # }
        result.body.add(loopNode)
    of tkIdentifier:
      if p.current.value == "println":
        p.advance()
        p.expect(tkSymbol) # (
        var call = Node(kind: nkCall, fnName: "println", args: @[])
        if p.current.kind == tkString:
          call.args.add(Node(kind: nkStrLit, value: p.current.value))
          p.advance()
        p.expect(tkSymbol) # )
        result.body.add(call)
      else:
        p.advance()
    else:
      p.advance()
  
  p.expect(tkSymbol) # }

proc parse*(tokens: seq[Token]): Node =
  var p = initParser(tokens)
  result = Node(kind: nkProgram, stmts: @[])
  
  while p.current.kind != tkEof:
    echo "Parsing..."
    case p.current.kind
    of tkKeyword:
      if p.current.value == "main":
        result.stmts.add(p.parseFuncDecl())
      else:
        p.advance()
    else:
      p.advance()
