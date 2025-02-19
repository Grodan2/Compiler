%{
  #include "parser.tab.hh"
  #include "Node.h"
  #include <cstdio>
  #include <string>

  #define YY_DECL yy::parser::symbol_type yylex()
  YY_DECL;

  extern int yylineno;
  int lexical_errors = 0;

  static yy::parser::location_type make_location() {
      return yy::parser::location_type(
          yy::position(nullptr, yylineno, 1),
          yy::position(nullptr, yylineno, 1)
      );
  }
%}

%option noyywrap

%%

\n { yylineno++; } // Increment line number on newline

"&&"                   { return yy::parser::make_AND(std::string(yytext), make_location()); }
"||"                   { return yy::parser::make_OR(std::string(yytext), make_location()); }
"=="                   { return yy::parser::make_EQ(std::string(yytext), make_location()); }
">"                    { return yy::parser::make_GT(std::string(yytext), make_location()); }
"<"                    { return yy::parser::make_LT(std::string(yytext), make_location()); }
"="                    { return yy::parser::make_ASSIGN(std::string(yytext), make_location()); }
"!"                    { return yy::parser::make_NOT(std::string(yytext), make_location()); }
"\+"                   { return yy::parser::make_PLUS(std::string(yytext), make_location()); }
"-"                    { return yy::parser::make_MINUS(std::string(yytext), make_location()); }
"\*"                   { return yy::parser::make_MULT(std::string(yytext), make_location()); }
"\."                   { return yy::parser::make_DOT(std::string(yytext), make_location()); }
","                    { return yy::parser::make_COMMA(std::string(yytext), make_location()); }
";"                    { return yy::parser::make_SEMICOLON(std::string(yytext), make_location()); }
"{"                    { return yy::parser::make_LBRACE(std::string(yytext), make_location()); }
"}"                    { return yy::parser::make_RBRACE(std::string(yytext), make_location()); }
"\["                   { return yy::parser::make_LBRACK(std::string(yytext), make_location()); }
"\]"                   { return yy::parser::make_RBRACK(std::string(yytext), make_location()); }
"\("                   { return yy::parser::make_LPAREN(std::string(yytext), make_location()); }
"\)"                   { return yy::parser::make_RPAREN(std::string(yytext), make_location()); }

"length"               { return yy::parser::make_LENGTH(std::string(yytext), make_location()); }
"public"               { return yy::parser::make_PUBLIC(std::string(yytext), make_location()); }
"class"                { return yy::parser::make_CLASS(std::string(yytext), make_location()); }
"static"               { return yy::parser::make_STATIC(std::string(yytext), make_location()); }
"void"                 { return yy::parser::make_VOID(std::string(yytext), make_location()); }
"main"                 { return yy::parser::make_MAIN(std::string(yytext), make_location()); }
"String"               { return yy::parser::make_STRING(std::string(yytext), make_location()); }
"return"               { return yy::parser::make_RETURN(std::string(yytext), make_location()); }
"if"                   { return yy::parser::make_IF(std::string(yytext), make_location()); }
"else"                 { return yy::parser::make_ELSE(std::string(yytext), make_location()); }
"while"                { return yy::parser::make_WHILE(std::string(yytext), make_location()); }
"System.out.println"   { return yy::parser::make_PRINTLN(std::string(yytext), make_location()); }
"new"                  { return yy::parser::make_NEW(std::string(yytext), make_location()); }
"true"                 { return yy::parser::make_TRUE(std::string(yytext), make_location()); }
"false"                { return yy::parser::make_FALSE(std::string(yytext), make_location()); }
"this"                 { return yy::parser::make_THIS(std::string(yytext), make_location()); }
"boolean"              { return yy::parser::make_BOOLEAN(std::string(yytext), make_location()); }
"int"                  { return yy::parser::make_INTKW(std::string(yytext), make_location()); }


[A-Za-z_][A-Za-z0-9_]* { return yy::parser::make_IDENTIFIER(std::string(yytext), make_location()); }
[0-9]+                 { return yy::parser::make_INTLIT(std::string(yytext), make_location()); }
[ \t\r]+               { /* skip whitespace (excluding newlines) */ }
"//"[^\n]*             { /* skip single-line comment */ }
"/*"([^*]|\*+[^*/])*\*+"/" { /* skip multi-line comment */ }

<<EOF>> {
    return yy::parser::make_YYEOF(make_location());
}

%%