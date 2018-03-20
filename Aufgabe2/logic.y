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
formula:  atom{puts("bison: formula = atom");}
		| NOT formula {puts("bison: formula = not formula");}
		| OPENPAR formula CLOSEPAR {puts("bison: formula = ( formula )");}
		| TOP {puts("bison: formula = top");}
		| BOTTOM {puts("bison: formula = bottom");}
		| formula AND formula {puts("bison: formula = formula and formula");}
		| formula OR formula {puts("bison: formula = formula or formula");}
		| formula IMPLICATION formula {puts("bison: formula = formula implication formula");}
		| formula EQUIVALENCE formula {puts("bison: formula = formula implication formula");}
		| ALL VARIABLE formula {puts("bison: formula = all variable formula");}
		| EXIST VARIABLE formula {puts("bison: formula = exist variable formula");};
  
termsequence: term {puts("bison: termsequence = term");}
		| 	  termsequence COMMA term {puts("bison: termsequence = termsequence comma term");};
		
term:     VARIABLE {puts("bison: term = variable");}
		| FUNCTION {puts("bison: term = function");}
		| FUNCTION OPENPAR termsequence CLOSEPAR {puts("bison: term = function(termsequence)");};
		
atom:     PREDICATE {puts("bison: atom= predicate");}
		| PREDICATE OPENPAR termsequence CLOSEPAR {puts("bison: atom = predicate(termsequence)");}
		| term {puts("bison: atom = term");};
		



%%

int yyerror(char* err)
{
   printf("Error: %s", err);
   return 0;
}


int main (int argc, char* argv[])
{
  puts("bison: Starting");
  return yyparse();
  puts("bison: Ending");
}