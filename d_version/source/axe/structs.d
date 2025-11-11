module axe.structs;

enum TokenType
{
    main,
    println,
    loop,
    break_,
    str,
    semicolon,
    lbrace,
    rbrace,
    def,
    identifier,
    whitespace,
    newline,
    lparen,
    rparen,
    lbracket,
    rbracket,
    comma,
    dot,
    colon,
    operator
}

struct Token
{
    TokenType type;
    string value;
}

struct ASTNode
{
    string nodeType;
    ASTNode[] children;
    string value;
}
