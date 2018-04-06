 /* 
     First parser
 */

%{
   #include <stdio.h>
   #include "structs.h"
   extern int yyerror(char* err);
   extern int yylex(void);
   
	formula endformula;  //jedes mal wenn etwas in eine Formel gespeichert wird überschreiben oder zusätzliches startsymbol
	
%}

%union { /*for yylval*/
   char* name; /*strdup(yytext)*/
   struct formula* f;
   struct termList* list;
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
formula:  atom{puts("bison: formula = atom");}
		| NOT formula {puts("bison: formula = not formula");}
		| OPENPAR formula CLOSEPAR {puts("bison: formula = ( formula )");}
		| TOP {puts("bison: formula = top");}
		| BOTTOM {puts("bison: formula = bottom");}
		| ALL term formula {puts("bison: formula = all variable formula");}
		| EXIST term formula {puts("bison: formula = exist variable formula");}
		| formula AND formula {puts("bison: formula = formula and formula");}
		| formula OR formula {puts("bison: formula = formula or formula");}
		| formula IMPLICATION formula {puts("bison: formula = formula implication formula");}
		| formula EQUIVALENCE formula {puts("bison: formula = formula equivalence formula");};
  
termsequence: term {puts("bison: termsequence = term");
					struct termList t =*$<list>1;
					puts(t.name);
					$<list>$=&t;
					}
			|termsequence COMMA term {puts("bison: termsequence = termsequence comma term");
					
					struct termList t=*$<list>3;
					t.list=$<list>1;
					puts("normal:");
					puts(t.name);
					puts(t.list->name);							
					
					struct termList copy;
					copy.name=strdup(t.name);
					copy.list=t.list;
					puts("copy:");
					puts(copy.name);
					puts(copy.list->name);	
					$<list>$=&copy;
					//printTermsequence(copy);
		};
		
term:     VARIABLE {puts("term = variable:");
					struct termList t;
					t.name=strdup($<name>1);
					puts(t.name);
					t.list=NULL;
					$<list>$=&t;
					}
		| FUNCTION {puts("bison: term = function");  /*Constant, no paramter list*/
					struct termList func;
					func.name=$<name>1;
					func.list=NULL;
					puts(func.name);
					$<list>$=&func;
					}
		| FUNCTION OPENPAR termsequence CLOSEPAR {puts("bison: term = function(termsequence)");
					struct termList func;
					func.name=$<name>1;
					puts(func.name);
					func.list=$<list>3;
					puts(func.list->name);
					puts(func.list->name);
					puts(func.list->name);
					$<list>$=&func;
		};
		
atom:     PREDICATE {puts("bison: atom= predicate");}
		| PREDICATE OPENPAR termsequence CLOSEPAR {puts("bison: atom = predicate(termsequence)");}
		| term {puts("bison: atom = term");};
		



%%

int yyerror(char* err)
{
   printf("Error: %s", err);
   return 0;
}

void printFormula(formula* f){
	
}

void addToList(termList* head, termList* tail){
	termList* pointer = head;
	if (pointer->list==NULL) puts("null");
	while(pointer->list!=NULL){
		puts(pointer->name);
		pointer=pointer->list;
	}
	pointer->list=tail;
}

void printTermsequence(termList tlist){
	puts("terms:");
	puts(tlist.name);
	int a=0;
	while((tlist.list!=NULL)&&(a<10)){
		a++;
		puts(tlist.list->name);
		tlist=*tlist.list;
	}
}


int main (int argc, char* argv[])
{
	
  puts("bison: Starting");
  return yyparse();
  puts("bison: Ending");
}