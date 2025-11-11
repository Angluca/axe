import 
    lexer,
    strformat

let source = """
// std.stdio;

main: void (args: array<string>) {
    println("Hello, world.");

    loop {
        println("What is up...");
        break;
    }
}
"""

let tokens = lex(source)

for token in tokens:
  echo fmt"{token.line}:{token.col} {token.kind} '{token.value}'"
