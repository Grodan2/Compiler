%skeleton "lalr1.cc"
%defines
%define parse.error verbose
%define api.value.type variant
%define api.token.constructor

%code requires{
  #include <string>
  #include "Node.h"
}

%code{
  #include <cstdio>
  #include <iostream>
  #define YY_DECL yy::parser::symbol_type yylex()
  YY_DECL;
  extern Node* root;
  extern int yylineno;
  extern int lexical_errors;
}

%token <std::string> CLASS PUBLIC STATIC VOID MAIN IF ELSE WHILE RETURN TRUE FALSE NEW THIS
%token <std::string> BOOLEAN INT STRING SYSTEM OUT PRINTLN
%token <std::string> AND OR NOT LT GT EQ PLUS MINUS MULT ASSIGN
%token <std::string> LBRACE RBRACE LPAREN RPAREN LBRACKET RBRACKET SEMICOLON DOT COMMA
%token <std::string> IDENTIFIER INTEGER
%token <std::string> END
%token <std::string> LENGTH

%left OR
%left AND
%left EQ
%left LT GT
%left PLUS MINUS
%left MULT
%right NOT

%type <Node*> Goal MainClass ClassDeclList ClassDeclaration VarDeclList VarDeclaration MethodDeclList MethodDeclaration StatementList Statement VarStmtList ParamListOpt ParamList ParamRest Type Expression
%type <Node*> ArgListOpt ArgList ArgListRest
%type <Node*> NonEmptyStatementList
%start Goal

%%

Goal
  : MainClass ClassDeclList
    {
      Node* n = new Node("Goal","",yylineno);
      n->children.push_back($1);
      n->children.push_back($2);
      root = n;
      $$ = root;
    }
  ;

NonEmptyStatementList
  : Statement
    {
      Node* n = new Node("StatementList","",yylineno);
      n->children.push_back($1);
      $$ = n;
    }
  | NonEmptyStatementList Statement
    {
      $$ = $1;
      $$->children.push_back($2);
    }
  ;

MainClass
  : PUBLIC CLASS IDENTIFIER LBRACE PUBLIC STATIC VOID MAIN LPAREN STRING LBRACKET RBRACKET IDENTIFIER RPAREN LBRACE NonEmptyStatementList RBRACE RBRACE
    {
      Node* n = new Node("MainClass",$3,yylineno);
      n->children.push_back($16);
      $$ = n;
    }
  ;


ClassDeclList
  : 
    {
      Node* n = new Node("ClassDeclList","",yylineno);
      $$ = n;
    }
  | ClassDeclList ClassDeclaration
    {
      $$ = $1;
      $$->children.push_back($2);
    }
  ;

ClassDeclaration
  : CLASS IDENTIFIER LBRACE VarDeclList MethodDeclList RBRACE
    {
      Node* n = new Node("ClassDeclaration",$2,yylineno);
      n->children.insert(n->children.end(),$4->children.begin(),$4->children.end());
      n->children.insert(n->children.end(),$5->children.begin(),$5->children.end());
      $$ = n;
    }
  ;

VarDeclList
  :
    {
      Node* n = new Node("VarDeclList","",yylineno);
      $$ = n;
    }
  | VarDeclList VarDeclaration
    {
      $$ = $1;
      $$->children.push_back($2);
    }
  ;

VarDeclaration
  : Type IDENTIFIER SEMICOLON
    {
      Node* n = new Node("VarDeclaration",$2,yylineno);
      n->children.push_back($1);
      $$ = n;
    }
  ;

MethodDeclList
  :
    {
      Node* n = new Node("MethodDeclList","",yylineno);
      $$ = n;
    }
  | MethodDeclList MethodDeclaration
    {
      $$ = $1;
      $$->children.push_back($2);
    }
  ;

MethodDeclaration
  : PUBLIC Type IDENTIFIER LPAREN ParamListOpt RPAREN LBRACE VarStmtList RETURN Expression SEMICOLON RBRACE
    {
      Node* n = new Node("MethodDeclaration",$3,yylineno);
      n->children.push_back($2);
      if($5) n->children.push_back($5);
      n->children.insert(n->children.end(),$8->children.begin(),$8->children.end());
      Node* ret = new Node("Return","",yylineno);
      ret->children.push_back($10);
      n->children.push_back(ret);
      $$ = n;
    }
  ;

ParamListOpt
  :
    {
      $$ = NULL;
    }
  | ParamList
    {
      $$ = $1;
    }
  ;

ParamList
  : Type IDENTIFIER ParamRest
    {
      Node* n = new Node("ParamList","",yylineno);
      Node* p = new Node("Param",$2,yylineno);
      p->children.push_back($1);
      n->children.push_back(p);
      if($3) {
        for(auto& c : $3->children) n->children.push_back(c);
      }
      $$ = n;
    }
  ;

ParamRest
  :
    {
      $$ = NULL;
    }
  | ParamRest COMMA Type IDENTIFIER
    {
      if(!$1) {
        Node* n = new Node("ParamListRest","",yylineno);
        Node* p = new Node("Param",$4,yylineno);
        p->children.push_back($3);
        n->children.push_back(p);
        $$ = n;
      } else {
        Node* p = new Node("Param",$4,yylineno);
        p->children.push_back($3);
        $1->children.push_back(p);
        $$ = $1;
      }
    }
  ;

Type
  : INT
    {
      Node* n = new Node("Type","int",yylineno);
      $$ = n;
    }
  | BOOLEAN
    {
      Node* n = new Node("Type","boolean",yylineno);
      $$ = n;
    }
  | STRING
    {
      Node* n = new Node("Type","String",yylineno);
      $$ = n;
    }
  | INT LBRACKET RBRACKET
    {
      Node* n = new Node("Type","int[]",yylineno);
      $$ = n;
    }
  | IDENTIFIER
    {
      Node* n = new Node("Type",$1,yylineno);
      $$ = n;
    }
  ;

VarStmtList
  :
    {
      Node* n = new Node("VarStmtList","",yylineno);
      $$ = n;
    }
  | VarStmtList VarDeclaration
    {
      $$ = $1;
      $$->children.push_back($2);
    }
  | VarStmtList Statement
    {
      $$ = $1;
      $$->children.push_back($2);
    }
  ;

StatementList
  :
    {
      Node* n = new Node("StatementList","",yylineno);
      $$ = n;
    }
  | StatementList Statement
    {
      $$ = $1;
      $$->children.push_back($2);
    }
  ;

Statement
  : LBRACE StatementList RBRACE
    {
      Node* n = new Node("Block","",yylineno);
      n->children.insert(n->children.end(),$2->children.begin(),$2->children.end());
      $$ = n;
    }
  | IF LPAREN Expression RPAREN Statement
    {
      Node* n = new Node("IfStatement","",yylineno);
      n->children.push_back($3);
      n->children.push_back($5);
      Node* emptyElse = new Node("EmptyElse","",yylineno);
      n->children.push_back(emptyElse);
      $$ = n;
    }
  | IF LPAREN Expression RPAREN Statement ELSE Statement
    {
      Node* n = new Node("IfStatement","",yylineno);
      n->children.push_back($3);
      n->children.push_back($5);
      n->children.push_back($7);
      $$ = n;
    }
  | WHILE LPAREN Expression RPAREN Statement
    {
      Node* n = new Node("WhileStatement","",yylineno);
      n->children.push_back($3);
      n->children.push_back($5);
      $$ = n;
    }
  | SYSTEM DOT OUT DOT PRINTLN LPAREN Expression RPAREN SEMICOLON
    {
      Node* n = new Node("PrintStatement","",yylineno);
      n->children.push_back($7);
      $$ = n;
    }
  | IDENTIFIER ASSIGN Expression SEMICOLON
    {
      Node* n = new Node("Assignment",$1,yylineno);
      n->children.push_back($3);
      $$ = n;
    }
  | IDENTIFIER LBRACKET Expression RBRACKET ASSIGN Expression SEMICOLON
    {
      Node* n = new Node("ArrayAssignment",$1,yylineno);
      n->children.push_back($3);
      n->children.push_back($6);
      $$ = n;
    }
  
  ;


ArgListOpt
  :
    {
      $$ = NULL;
    }
  | ArgList
    {
      $$ = $1;
    }
  ;

ArgList
  : Expression ArgListRest
    {
      Node* n = new Node("ArgList","",yylineno);
      n->children.push_back($1);
      if($2) {
        for(auto& x : $2->children) {
          n->children.push_back(x);
        }
      }
      $$ = n;
    }
  ;

ArgListRest
  :
    {
      $$ = NULL;
    }
  | COMMA Expression ArgListRest
    {
      if(!$3) {
        Node* n = new Node("ArgListRest","",yylineno);
        n->children.push_back($2);
        $$ = n;
      } else {
        $3->children.insert($3->children.begin(),$2);
        $$ = $3;
      }
    }
  ;

Expression
  : Expression AND Expression
    {
      Node* n = new Node("AndExpr","",yylineno);
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | Expression OR Expression
    {
      Node* n = new Node("OrExpr","",yylineno);
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | Expression DOT LENGTH
  {
    Node* n = new Node("ArrayLength","",yylineno);
    n->children.push_back($1);
    $$ = n;
  }
  | Expression LT Expression
    {
      Node* n = new Node("LessThanExpr","",yylineno);
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | Expression GT Expression
    {
      Node* n = new Node("GreaterThanExpr","",yylineno);
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | Expression EQ Expression
    {
      Node* n = new Node("EqualExpr","",yylineno);
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | Expression PLUS Expression
    {
      Node* n = new Node("AddExpr","",yylineno);
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | Expression MINUS Expression
    {
      Node* n = new Node("SubExpr","",yylineno);
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | Expression LBRACKET Expression RBRACKET
  {
    Node* n = new Node("ArrayAccess","",yylineno);
    n->children.push_back($1);
    n->children.push_back($3);
    $$ = n;
  }  
  | Expression MULT Expression
    {
      Node* n = new Node("MulExpr","",yylineno);
      n->children.push_back($1);
      n->children.push_back($3);
      $$ = n;
    }
  | INTEGER
    {
      Node* n = new Node("IntLiteral",$1,yylineno);
      $$ = n;
    }
  | TRUE
    {
      Node* n = new Node("BooleanLiteral","true",yylineno);
      $$ = n;
    }
  | FALSE
    {
      Node* n = new Node("BooleanLiteral","false",yylineno);
      $$ = n;
    }
  | IDENTIFIER
    {
      Node* n = new Node("Identifier",$1,yylineno);
      $$ = n;
    }
  | THIS
    {
      Node* n = new Node("ThisExpr","",yylineno);
      $$ = n;
    }
  | NEW INT LBRACKET Expression RBRACKET
    {
      Node* n = new Node("NewIntArray","",yylineno);
      n->children.push_back($4);
      $$ = n;
    }
  | NEW IDENTIFIER LPAREN RPAREN
    {
      Node* n = new Node("NewObject",$2,yylineno);
      $$ = n;
    }
  | NOT Expression
    {
      Node* n = new Node("NotExpr","",yylineno);
      n->children.push_back($2);
      $$ = n;
    }
  | LPAREN Expression RPAREN
    {
      $$ = $2;
    }
  | Expression DOT IDENTIFIER LPAREN ArgListOpt RPAREN
    {
      Node* n = new Node("MethodCall",$3,yylineno);
      n->children.push_back($1);
      if($5) {
        for(auto& x : $5->children) {
          n->children.push_back(x);
        }
      }
      $$ = n;
    }
  ;


%%
