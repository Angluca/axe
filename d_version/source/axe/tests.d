module axe.tests;

import axe.lexer;
import axe.parser;
import axe.renderer;
import axe.structs;
import std.string;
import std.algorithm;
import std.stdio;

unittest
{
    {
        auto tokens = lex("println \"hello\";");
        assert(tokens.length == 4);
        assert(tokens[0].type == TokenType.PRINTLN);
        assert(tokens[1].type == TokenType.WHITESPACE);
        assert(tokens[2].type == TokenType.STR);
        assert(tokens[2].value == "hello");
        assert(tokens[3].type == TokenType.SEMICOLON);
    }
    {
        auto tokens = lex("main { println \"test\"; }");
        auto ast = parse(tokens);
        assert(ast.nodeType == "Program");
        assert(ast.children.length == 1);
        assert(ast.children[0].nodeType == "Main");
        assert(ast.children[0].children[0].nodeType == "Println");
        assert(ast.children[0].children[0].value == "test");
    }
}
