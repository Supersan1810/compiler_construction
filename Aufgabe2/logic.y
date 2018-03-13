 /* 
     First parser
 */

%{
   #include <stdio.h>

   extern int yyerror(char* err);
   extern int yylex(void);
%}

%union {
   char* var; /*strdup(yytext)*/
}


%start formula

%token OPENPAR
%token CLOSEPAR
%token COMMA
%token TOP
%token BOTTOM
%token VARIABLE

%precedence EQUIVALENCE
%precedence IMPLICATION
%left  OR
%left  AND
%precedence  NOT
%precedence ALL EXIST
%precedence PREDICATE
%precedence FUNCTION
%precedence ERROR


%%
/* hier kommen die Regeln	*/
formula: atom{}
		| NOT formula {}
		| OPENPAR formula CLOSEPAR {}
		| TOP {}
		| BOTTOM {}
		| formula AND formula {}
		| formula OR formula {}
		| formula IMPLICATION formula {}
		| formula EQUIVALENCE formula {}
		| ALL VARIABLE formula {}
		| EXIST VARIABLE formula {};
  
term: VARIABLE {}
		| FUNCTION {};
		
atom: PREDICATE {}
		| term {};



%%

int yyerror(char* err)
{
   printf("Error: %s\n", err);
   return 0;
}


int main (int argc, char* argv[])
{
  
  return yyparse();
}