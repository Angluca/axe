import 
    os,
    lexer,
    parser,
    renderer

when isMainModule:
  let args = commandLineParams()
  if args.len < 1:
    echo "Usage: axe <filename>"
    quit(1)
  let source = readFile(args[0])
  let tokens = lex(source)
  echo tokens
  let ast = parser.parse(tokens)
  let ccode = renderer.render(ast)
  let fname = args[0] & ".c"
  writeFile(fname, ccode)
  echo "Generated " & fname
