import
  unittest,
  strutils,
  ../src/axe/[lexer, parser, renderer, structs]

suite "Lexer tests":
  test "Basic tokenization":
    let tokens = lex("""
      main {
        println "hello";
        loop {
          println "world";
          break;
        }
      }
    """)

    check tokens[0].typ == Main
    check tokens[1].typ == LBrace
    check tokens[2].typ == Println
    check tokens[3].typ == String
    check tokens[4].typ == Semicolon
    check tokens[5].typ == Loop
    check tokens[6].typ == LBrace
    check tokens[7].typ == Println
    check tokens[8].typ == String
    check tokens[9].typ == Semicolon
    check tokens[10].typ == Break
    check tokens[11].typ == Semicolon
    check tokens[12].typ == RBrace
    check tokens[13].typ == RBrace

suite "Parser tests":
  test "AST construction":
    let tokens = lex("""
      main {
        println "hello";
        loop {
          println "world";
          break;
        }
      }
    """)

    let ast = parse(tokens)

    check ast.nodeType == "Main"
    check ast.children.len == 2
    check ast.children[0].nodeType == "Println"
    check ast.children[0].value == "hello"
    check ast.children[1].nodeType == "Loop"
    check ast.children[1].children.len == 2
    check ast.children[1].children[0].nodeType == "Println"
    check ast.children[1].children[0].value == "world"
    check ast.children[1].children[1].nodeType == "Break"

suite "Renderer tests":
  test "C code generation":
    let tokens = lex("""
      main {
        println "hello";
      }
    """)
    let ast = parse(tokens)
    let cCode = generateC(ast)

    check contains(cCode, "#include <stdio.h>")
    check contains(cCode, "int main() {")
    check contains(cCode, "printf(\"%s\\n\", \"hello\");")

  test "ASM code generation":
    let tokens = lex("""
      main {
        println "hello";
      }
    """)
    let ast = parse(tokens)
    let asmCode = generateAsm(ast)

    check contains(asmCode, "section .data")
    check contains(asmCode, "fmt db \"%s\", 10, 0")
    check contains(asmCode, "global _start")
    check contains(asmCode, "push hello")
    check contains(asmCode, "call printf")
