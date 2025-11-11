module axe.renderer;

import std.string;
import std.array;
import axe.structs;
import std.exception;

string generateC(ASTNode ast)
{
    string cCode;
    string[] includes = ["#include <stdio.h>"];

    switch (ast.nodeType)
    {
    case "Program":
        foreach (child; ast.children)
        {
            if (child.nodeType == "Function")
            {
                auto funcDecl = child.value.split("(");
                string funcName = funcDecl[0];
                string args = funcDecl.length > 1 ?
                    funcDecl[1].strip(")") : "";
                cCode ~= "void " ~ funcName ~ "(" ~
                    (args.length > 0 ? "int " ~ args.replace(",", ", int ") : "void") ~ ");\n";
            }
        }
        cCode ~= includes.join("\n") ~ "\n\n";
        foreach (child; ast.children)
        {
            cCode ~= generateC(child) ~ "\n";
        }
        break;

    case "Main":
        cCode ~= "int main() {\n";
        foreach (child; ast.children)
        {
            final switch (child.nodeType)
            {
            case "Println":
                cCode ~= "printf(\"%s\\n\", \"" ~ child.value ~ "\");\n";
                break;
            case "Loop":
                cCode ~= "while (1) {\n";
                foreach (loopChild; child.children)
                {
                    final switch (loopChild.nodeType)
                    {
                    case "Println":
                        cCode ~= "printf(\"%s\\n\", \"" ~ loopChild.value ~ "\");\n";
                        break;
                    case "Break":
                        cCode ~= "break;\n";
                        break;
                    }
                }
                cCode ~= "}\n";
                break;
            case "Break":
                cCode ~= "break;\n";
                break;
            case "FunctionCall":
                auto funcDecl = child.value.split("(");
                string funcName = funcDecl[0];
                string args = funcDecl.length > 1 ?
                    funcDecl[1].strip(")") : "";
                cCode ~= funcName ~ "(" ~ args ~ ");\n";
                break;
            }
        }
        cCode ~= "return 0;\n}";
        break;

    case "Function":
        auto funcDecl = ast.value.split("(");
        string funcName = funcDecl[0];
        string args = funcDecl.length > 1 ?
            funcDecl[1].strip(")") : "";
        cCode ~= "void " ~ funcName ~ "(" ~
            (args.length > 0 ? "int " ~ args.replace(",", ", int ") : "void") ~ ") {\n";
        foreach (child; ast.children)
        {
            final switch (child.nodeType)
            {
            case "Println":
                cCode ~= "printf(\"%s\\n\", \"" ~ child.value ~ "\");\n";
                break;
            case "FunctionCall":
                auto callDecl = child.value.split("(");
                string callName = callDecl[0];
                string callArgs = callDecl.length > 1 ?
                    callDecl[1].strip(")") : "";
                cCode ~= callName ~ "(" ~ callArgs ~ ");\n";
                break;
            }
        }
        cCode ~= "}";
        break;

    case "FunctionCall":
        auto funcDecl = ast.value.split("(");
        string funcName = funcDecl[0];
        string args = funcDecl.length > 1 ?
            funcDecl[1].strip(")") : "";
        cCode ~= funcName ~ "(" ~ args ~ ");\n";
        break;

    default:
        enforce(false, "Unsupported node type for C generation: " ~ ast.nodeType);
    }

    return cCode;
}

string generateAsm(ASTNode ast)
{
    string asmCode;

    final switch (ast.nodeType)
    {
    case "Program":
        if (ast.children.length > 0 && ast.children[0].nodeType == "Main")
        {
            asmCode = generateAsm(ast.children[0]);
        }
        break;

    case "Main":
        asmCode = `
                section .data
                    fmt db "%s", 10, 0
                    hello db "hello", 0
                section .text
                    global _start
                _start:
            `;
        foreach (child; ast.children)
        {
            final switch (child.nodeType)
            {
            case "Println":
                asmCode ~= `
                            push hello
                            push fmt
                            call printf
                            add esp, 8
                        `;
                break;
            case "Loop":
                asmCode ~= "loop_start:\n";
                foreach (loopChild; child.children)
                {
                    final switch (loopChild.nodeType)
                    {
                    case "Println":
                        asmCode ~= `
                                        push hello
                                        push fmt
                                        call printf
                                        add esp, 8
                                    `;
                        break;
                    }
                }
                break;
            }
        }
        break;
    }

    return asmCode;
}
