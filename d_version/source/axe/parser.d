module axe.parser;

import std.exception : enforce;
import std.string;
import axe.structs : ASTNode, Token, TokenType;

ASTNode parse(Token[] tokens)
{
    size_t pos = 0;
    ASTNode ast = ASTNode("Program", [], "");

    string parseType()
    {
        while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
            pos++;
        enforce(pos < tokens.length, "Expected type after ':'");

        string typeName;
        if (tokens[pos].type == TokenType.identifier)
        {
            typeName = tokens[pos].value;
            pos++;
            if (pos < tokens.length && tokens[pos].type == TokenType.operator && tokens[pos].value == "*")
            {
                typeName ~= "*";
                pos++;
            }
        }
        else
        {
            enforce(false, "Invalid type specification");
        }

        return typeName;
    }

    string parseArgs()
    {
        string[] args;
        while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
            pos++;

        if (pos < tokens.length && tokens[pos].type == TokenType.lparen)
        {
            pos++;
            while (pos < tokens.length && tokens[pos].type != TokenType.rparen)
            {
                if (tokens[pos].type == TokenType.whitespace || tokens[pos].type == TokenType.comma)
                {
                    pos++;
                }
                else if (tokens[pos].type == TokenType.identifier)
                {
                    string argName = tokens[pos].value;
                    pos++;
                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;

                    if (pos < tokens.length && tokens[pos].type == TokenType.colon)
                    {
                        pos++;
                        string argType = parseType();
                        args ~= argType ~ " " ~ argName;
                    }
                    else
                    {
                        args ~= "int " ~ argName;
                    }
                }
                else
                {
                    enforce(false, "Unexpected token in argument list");
                }
            }
            enforce(pos < tokens.length && tokens[pos].type == TokenType.rparen, "Expected ')' after arguments");
            pos++;
        }

        return args.join(", ");
    }

    while (pos < tokens.length)
    {
        switch (tokens[pos].type)
        {
        case TokenType.main:
            pos++;
            while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                pos++;

            enforce(pos < tokens.length && tokens[pos].type == TokenType.lbrace, "Expected '{' after main");
            pos++;

            ASTNode mainNode = ASTNode("Main", [], "");
            while (pos < tokens.length && tokens[pos].type != TokenType.rbrace)
            {
                switch (tokens[pos].type)
                {
                case TokenType.whitespace, TokenType.newline:
                    pos++;
                    break;

                case TokenType.println:
                    pos++;
                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;

                    enforce(pos < tokens.length && tokens[pos].type == TokenType.str, "Expected string after println");
                    mainNode.children ~= ASTNode("Println", [], tokens[pos].value);
                    pos++;

                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;
                    enforce(pos < tokens.length && tokens[pos].type == TokenType.semicolon, "Expected ';' after println");
                    pos++;
                    break;

                case TokenType.loop:
                    pos++;
                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;

                    enforce(pos < tokens.length && tokens[pos].type == TokenType.lbrace, "Expected '{' after loop");
                    pos++;

                    ASTNode loopNode = ASTNode("Loop", [], "");
                    while (pos < tokens.length && tokens[pos].type != TokenType.rbrace)
                    {
                        switch (tokens[pos].type)
                        {
                        case TokenType.whitespace, TokenType.newline:
                            pos++;
                            break;

                        case TokenType.println:
                            pos++;
                            while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                                pos++;

                            enforce(pos < tokens.length && tokens[pos].type == TokenType.str, "Expected string after println");
                            loopNode.children ~= ASTNode("Println", [], tokens[pos].value);
                            pos++;

                            while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                                pos++;
                            enforce(pos < tokens.length && tokens[pos].type == TokenType.semicolon, "Expected ';' after println");
                            pos++;
                            break;

                        case TokenType.break_:
                            pos++;
                            while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                                pos++;

                            enforce(pos < tokens.length && tokens[pos].type == TokenType.semicolon, "Expected ';' after break");
                            pos++;
                            loopNode.children ~= ASTNode("Break", [], "");
                            break;

                        default:
                            enforce(false, "Unexpected token in loop body");
                        }
                    }

                    enforce(pos < tokens.length && tokens[pos].type == TokenType.rbrace, "Expected '}' after loop body");
                    pos++;
                    mainNode.children ~= loopNode;
                    break;

                case TokenType.break_:
                    pos++;
                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;

                    enforce(pos < tokens.length && tokens[pos].type == TokenType.semicolon, "Expected ';' after break");
                    pos++;
                    mainNode.children ~= ASTNode("Break", [], "");
                    break;

                case TokenType.identifier:
                    string funcName = tokens[pos].value;
                    pos++;
                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;

                    enforce(pos < tokens.length && tokens[pos].type == TokenType.lparen, "Expected '(' after function name");
                    pos++;
                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;

                    enforce(pos < tokens.length && tokens[pos].type == TokenType.rparen, "Expected ')' after function arguments");
                    pos++;
                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;

                    enforce(pos < tokens.length && tokens[pos].type == TokenType.semicolon, "Expected ';' after function call");
                    pos++;
                    mainNode.children ~= ASTNode("FunctionCall", [], funcName);
                    break;

                default:
                    enforce(false, "Unexpected token in main body");
                }
            }

            enforce(pos < tokens.length && tokens[pos].type == TokenType.rbrace, "Expected '}' after main body");
            pos++;
            ast.children ~= mainNode;
            break;

        case TokenType.def:
            pos++;
            while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                pos++;

            enforce(pos < tokens.length && tokens[pos].type == TokenType.identifier, "Expected function name after 'def'");
            string funcName = tokens[pos].value;
            pos++;

            string args = parseArgs();
            while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                pos++;

            enforce(pos < tokens.length && tokens[pos].type == TokenType.lbrace, "Expected '{' after function declaration");
            pos++;

            ASTNode funcNode = ASTNode("Function", [], funcName ~ "(" ~ args ~ ")");
            while (pos < tokens.length && tokens[pos].type != TokenType.rbrace)
            {
                switch (tokens[pos].type)
                {
                case TokenType.whitespace, TokenType.newline:
                    pos++;
                    break;

                case TokenType.println:
                    pos++;
                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;

                    enforce(pos < tokens.length && tokens[pos].type == TokenType.str, "Expected string after println");
                    funcNode.children ~= ASTNode("Println", [], tokens[pos].value);
                    pos++;

                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;
                    enforce(pos < tokens.length && tokens[pos].type == TokenType.semicolon, "Expected ';' after println");
                    pos++;
                    break;

                case TokenType.identifier:
                    string callName = tokens[pos].value;
                    pos++;
                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;

                    enforce(pos < tokens.length && tokens[pos].type == TokenType.lparen,
                        "Expected '(' after function name");
                    pos++;
                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;

                    enforce(pos < tokens.length && tokens[pos].type == TokenType.rparen,
                        "Expected ')' after function arguments");
                    pos++;
                    while (pos < tokens.length && tokens[pos].type == TokenType.whitespace)
                        pos++;

                    enforce(pos < tokens.length && tokens[pos].type == TokenType.semicolon,
                        "Expected ';' after function call");
                    pos++;
                    funcNode.children ~= ASTNode("FunctionCall", [], callName);
                    break;

                default:
                    enforce(false, "Unexpected token in function body");
                }
            }

            enforce(pos < tokens.length && tokens[pos].type == TokenType.rbrace, "Expected '}' after function body");
            pos++;
            ast.children ~= funcNode;
            break;

        case TokenType.whitespace, TokenType.newline:
            pos++;
            break;

        default:
            enforce(false, "Unexpected token at top level");
        }
    }

    return ast;
}
