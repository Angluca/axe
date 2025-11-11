module axe.lexer;

import std.exception;
import std.string;
import std.algorithm.iteration;
import axe.structs;

Token[] lex(string source)
{
    import std.ascii;
    
    Token[] tokens;
    size_t pos = 0;

    while (pos < source.length)
    {
        switch (source[pos])
        {
        case '*':
            if (tokens.length > 0 && tokens[$ - 1].type == TokenType.identifier)
            {
                tokens[$ - 1].value ~= "*";
                pos++;
            }
            else
            {
                enforce(false, "Unexpected '*'");
            }
            break;

        case ' ', '\t', '\r':
            tokens ~= Token(TokenType.whitespace, source[pos .. pos + 1]);
            pos++;
            break;

        case '\n':
            tokens ~= Token(TokenType.newline, "\n");
            pos++;
            break;

        case '{':
            tokens ~= Token(TokenType.lbrace, "{");
            pos++;
            break;

        case '}':
            tokens ~= Token(TokenType.rbrace, "}");
            pos++;
            break;

        case ';':
            tokens ~= Token(TokenType.semicolon, ";");
            pos++;
            break;

        case ':':
            tokens ~= Token(TokenType.colon, ":");
            pos++;
            break;

        case '"':
            size_t ending = source.indexOf('"', pos + 1);
            enforce(ending != -1, "Unterminated string");
            tokens ~= Token(TokenType.str, source[pos + 1 .. ending]);
            pos = ending + 1;
            break;

        case '(', ')', ',':
            tokens ~= Token(
                source[pos] == '(' ? TokenType.lparen : source[pos] == ')' ? TokenType.rparen
                    : TokenType.comma,
                    source[pos .. pos + 1]
            );
            pos++;
            break;

        case '[':
            tokens ~= Token(TokenType.lbracket, "[");
            pos++;
            break;

        case ']':
            tokens ~= Token(TokenType.rbracket, "]");
            pos++;
            break;

        case '.':
            tokens ~= Token(TokenType.dot, ".");
            pos++;
            break;

        default:
            if (pos + 4 <= source.length && source[pos .. pos + 4] == "main")
            {
                tokens ~= Token(TokenType.main, "main");
                pos += 4;
            }
            else if (pos + 7 <= source.length && source[pos .. pos + 7] == "println")
            {
                tokens ~= Token(TokenType.println, "println");
                pos += 7;
            }
            else if (pos + 4 <= source.length && source[pos .. pos + 4] == "loop")
            {
                tokens ~= Token(TokenType.loop, "loop");
                pos += 4;
            }
            else if (pos + 5 <= source.length && source[pos .. pos + 5] == "break")
            {
                tokens ~= Token(TokenType.break_, "break");
                pos += 5;
            }
            else if (pos + 3 <= source.length && source[pos .. pos + 3] == "def")
            {
                tokens ~= Token(TokenType.def, "def");
                pos += 3;
            }
            else if (source[pos].isAlphaNum())
            {
                size_t start = pos;
                while (pos < source.length && (source[pos].isAlphaNum() || source[pos] == '_'))
                {
                    pos++;
                }
                tokens ~= Token(TokenType.identifier, source[start .. pos]);
            }
            else
            {
                enforce(false, "Unexpected character: " ~ source[pos .. pos + 1]);
            }
        }
    }

    return tokens;
}
