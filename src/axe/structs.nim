type
    TokenType* = enum
        Main,
        Println,
        Loop,
        Break,
        String,
        Semicolon,
        LBrace,
        RBrace

    Token* = object
        typ*: TokenType
        value*: string

    ASTNode* = object
        nodeType*: string
        children*: seq[ASTNode]
        value*: string
