%top{
    #include "parser.tab.hh"
    #define YY_DECL yy::parser::symbol_type yylex()
    #include "Node.h"

    int lexical_errors = 0;
}

%option yylineno noyywrap nounput batch noinput stack 

%%

"class"         { return yy::parser::make_CLASS(yytext); }
"public"        { return yy::parser::make_PUBLIC(yytext); }
"static"        { return yy::parser::make_STATIC(yytext); }
"void"          { return yy::parser::make_VOID(yytext); }
"main"          { return yy::parser::make_MAIN(yytext); }
"if"            { return yy::parser::make_IF(yytext); }
"else"          { return yy::parser::make_ELSE(yytext); }
"while"         { return yy::parser::make_WHILE(yytext); }
"return"        { return yy::parser::make_RETURN(yytext); }
"true"          { return yy::parser::make_TRUE(yytext); }
"false"         { return yy::parser::make_FALSE(yytext); }
"new"           { return yy::parser::make_NEW(yytext); }
"this"          { return yy::parser::make_THIS(yytext); }
"int"           { return yy::parser::make_INT(yytext); }
"boolean"       { return yy::parser::make_BOOLEAN(yytext); }
"String"        { return yy::parser::make_STRING(yytext); }
"System"        { return yy::parser::make_SYSTEM(yytext); }
"out"           { return yy::parser::make_OUT(yytext); }
"println"       { return yy::parser::make_PRINTLN(yytext); }

"&&"            { return yy::parser::make_AND(yytext); }
"||"            { return yy::parser::make_OR(yytext); }
"!"             { return yy::parser::make_NOT(yytext); }
"<"             { return yy::parser::make_LT(yytext); }
">"             { return yy::parser::make_GT(yytext); }
"=="            { return yy::parser::make_EQ(yytext); }
"+"             { return yy::parser::make_PLUS(yytext); }
"-"             { return yy::parser::make_MINUS(yytext); }
"*"             { return yy::parser::make_MULT(yytext); }
"="             { return yy::parser::make_ASSIGN(yytext); }

"{"             { return yy::parser::make_LBRACE(yytext); }
"}"             { return yy::parser::make_RBRACE(yytext); }
"("             { return yy::parser::make_LPAREN(yytext); }
")"             { return yy::parser::make_RPAREN(yytext); }
"["             { return yy::parser::make_LBRACKET(yytext); }
"]"             { return yy::parser::make_RBRACKET(yytext); }
";"             { return yy::parser::make_SEMICOLON(yytext); }
"."             { return yy::parser::make_DOT(yytext); }
","             { return yy::parser::make_COMMA(yytext); }

[a-zA-Z_][a-zA-Z0-9_]* { return yy::parser::make_IDENTIFIER(yytext); }
[0-9]+ { return yy::parser::make_INTEGER(yytext); }
[ \t\n\r]+ {}
"//"[^\n]* { }
"/*"([^*]|\*+[^*/])*"*/" { }

. { 
    if (!lexical_errors) {
        fprintf(stderr, "Lexical errors found! See logs:\n");
        lexical_errors = 1;
    }
    fprintf(stderr, "\t@error at line %d. Character '%s' not recognized\n", yylineno, yytext);
}

<<EOF>> { return 0; }
