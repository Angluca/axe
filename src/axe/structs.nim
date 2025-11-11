type
    TokenType* = enum
        Main,
        Println,
        Loop,
        Break,
        String,
        Semicolon,
        LBrace,
        RBrace,
        Def,
        Identifier

    Token* = object
        typ*: TokenType
        value*: string

    ASTNode* = object
        nodeType*: string
        children*: seq[ASTNode]
        value*: string
