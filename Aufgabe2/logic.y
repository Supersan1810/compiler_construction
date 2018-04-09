 /* 
     First parser
 */

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "structs.h"
	//#define DEBUG
	
	extern int yyerror(char* err);
	extern int yylex(void);
	/*extern char* strdup(char*);
	extern char* strcat(char*, char*);
	extern int strcmp(char*,char*);
	extern int strcpy(char*,char*);*/
	void addToList(termSequence* head, termSequence* tail);
	void debugPrintTermsequence(termSequence* tlist);
	void printFormula(formula* f,int indent);
	formula* createFormula(fType t,char* name);
	char* termsequenceToStr(termSequence* tlist, int indent);
	char* indentStr(int n);
   
	formula* result; 
	
%}

%union { /*for yylval*/
   char* name;
   struct formula* f;
   struct termSequence* list;
}


%start result

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
result: formula {	
					#ifdef DEBUG
						puts("bison: Reached End. Formula tree:");
					#endif
					result=$<f>1;
					printFormula(result,0);
};

formula:  atom {
					$<f>$=$<f>1;
					#ifdef DEBUG
						puts("bison: formula = atom");
						puts($<f>1->name);
					#endif
					}
		| NOT formula {
					formula* f=createFormula(E_NOT,strdup("NOT"));
					f->leftFormula=$<f>2;
					$<f>$=f;
					#ifdef DEBUG
						puts("bison: formula = not formula");
						puts(f->name);
					#endif
					}
		| OPENPAR formula CLOSEPAR {
					$<f>$=$<f>1;	
					#ifdef DEBUG
						puts("bison: formula = ( formula )");	
					#endif
			}
		| TOP {
					formula* f=createFormula(E_TOP,strdup("TOP"));
					$<f>$=f;
					#ifdef DEBUG
						puts("bison: formula = top");
						puts(f->name);
					#endif
			}
		| BOTTOM {
					formula* f=createFormula(E_BOTTOM,strdup("BOTTOM"));
					$<f>$=f;
					#ifdef DEBUG
						puts("bison: formula = bottom");
						puts(f->name);
					#endif
			}
		| ALL term formula {
					formula* f=createFormula(E_ALL,strdup("ALL"));
					f->list=$<list>2;
					f->leftFormula=$<f>3;
					$<f>$=f;
					#ifdef DEBUG
						puts("bison: formula = all variable formula");
						puts(f->name);
					#endif
					}
		| EXIST term formula {
					formula* f=createFormula(E_EXIST,strdup("EXIST"));
					f->list=$<list>2;
					f->leftFormula=$<f>3;
					$<f>$=f;
					#ifdef DEBUG
						puts("bison: formula = exist variable formula");
						puts(f->name);
					#endif
					}
		| formula AND formula {
					formula* f=createFormula(E_AND,strdup("AND"));
					f->leftFormula=$<f>1;
					f->rightFormula=$<f>3;
					$<f>$=f;
					#ifdef DEBUG
						puts("bison: formula = formula and formula");
						puts(f->name);
					#endif
					}
		| formula OR formula {
					formula* f=createFormula(E_OR,strdup("OR"));
					f->leftFormula=$<f>1;
					f->rightFormula=$<f>3;
					$<f>$=f;
					#ifdef DEBUG
						puts("bison: formula = formula or formula");
						puts(f->name);
					#endif
					}
		| formula IMPLICATION formula {
					formula* f=createFormula(E_IMPLICATION,strdup("IMPLICATION"));
					f->leftFormula=$<f>1;
					f->rightFormula=$<f>3;
					$<f>$=f;
					#ifdef DEBUG
						puts("bison: formula = formula implication formula");
						puts(f->name);
					#endif
					}
		| formula EQUIVALENCE formula {
					formula* f=createFormula(E_EQUIVALENCE,strdup("EQUIVALENCE"));
					f->leftFormula=$<f>1;
					f->rightFormula=$<f>3;
					$<f>$=f;
					#ifdef DEBUG
						puts(f->name);
						puts("bison: formula = formula equivalence formula");
					#endif
					};
  
termsequence: term {
					struct termSequence* t =$<list>1;
					$<list>$=t;
					#ifdef DEBUG
						puts("bison: termsequence = term");
						puts(t->name);
					#endif
					}
			|termsequence COMMA term {
					struct termSequence* t=$<list>1;
					addToList(t,$<list>3); /*x->y */						
					$<list>$=t;
					#ifdef DEBUG
						puts("bison: termsequence = termsequence comma term");
						debugPrintTermsequence(t);
					#endif
		};
		
term:     VARIABLE {
					struct termSequence* t=(termSequence*)malloc(sizeof(termSequence));
					t->name=$<name>1;
					t->list=NULL;
					$<list>$=t;
					#ifdef DEBUG
						puts("term = variable:");
						puts(t->name);
					#endif
					}
		| FUNCTION {
					struct termSequence* func=(termSequence*)malloc(sizeof(termSequence));
					func->name=$<name>1;
					func->list=NULL;
					$<list>$=func;
					#ifdef DEBUG
						puts("bison: term = function");  /*Constant, no paramter list*/
						puts(func->name);
					#endif
					}
		| FUNCTION OPENPAR termsequence CLOSEPAR {
					struct termSequence* func=(termSequence*)malloc(sizeof(termSequence));
					func->name=$<name>1;
					func->list=$<list>3;
					$<list>$=func;
					#ifdef DEBUG
						puts("bison: term = function(termsequence)");
						puts(func->name);
						debugPrintTermsequence(func->list);
					#endif
		};
		
atom:     PREDICATE {
					struct formula* atom=createFormula(E_ATOM,$<name>1);
					$<f>$=atom;
					#ifdef DEBUG
						puts("bison: atom= predicate");
						puts(atom->name);
					#endif
					}
		| PREDICATE OPENPAR termsequence CLOSEPAR {
					struct formula* atom=createFormula(E_ATOM,$<name>1);
					atom->list=$<list>3;
					$<f>$=atom;	
					#ifdef DEBUG
						puts("bison: atom = predicate(termsequence)");
						puts(atom->name);
					#endif
					}
		| term {
					struct formula* atom=createFormula(E_ATOM,$<list>1->name);
					atom->list=$<list>1->list; /* required if term = function(termSequence)*/
					$<f>$=atom;	
					#ifdef DEBUG
						puts("bison: atom = term");
						puts(atom->name);
					#endif
					};
%%

int yyerror(char* err)
{
   printf("Error: %s", err);
   return 0;
}

void printFormula(formula* f,int indent){
	/*puts(f->name);*/
	if(f!=NULL){
		printf("%s%s\n",indentStr(indent),f->name);
		indent++;
		
		switch(f->type){
			case E_ATOM:
				if((f->list)!=NULL){
					printf("%s%s\n",indentStr(indent),termsequenceToStr(f->list,indent));
				}
				break;
			case E_AND:
				printFormula(f->leftFormula,indent);
				printFormula(f->rightFormula,indent);
				break;
			case E_ALL:
				if(f->list!=NULL)
					printf("%s%s\n",indentStr(indent),termsequenceToStr(f->list,indent));
				printFormula(f->leftFormula,indent);
				printFormula(f->rightFormula,indent);
				break;
			case E_BOTTOM:
				break;
			case E_EQUIVALENCE:
				printFormula(f->leftFormula,indent);
				printFormula(f->rightFormula,indent);
				break;
			case E_EXIST:
				if(f->list!=NULL)
					printf("%s%s\n",indentStr(indent),termsequenceToStr(f->list,indent));
				printFormula(f->leftFormula,indent);
				printFormula(f->rightFormula,indent);
				break;
			case E_IMPLICATION:
				printFormula(f->leftFormula,indent);
				printFormula(f->rightFormula,indent);
				break;
			case E_NOT:
				printFormula(f->leftFormula,indent);
				break;
			case E_OR:
				printFormula(f->leftFormula,indent);
				printFormula(f->rightFormula,indent);
				break;
			case E_TOP:
				break;
		}
	}	
}

char* indentStr(int n)
{
	char* result=(char*)malloc(n*strlen("  "));
	strcpy(result,"");
	
	for (int i=0;i<n;i++)
	{
		strcat(result,"  ");
	}
	return result;
}

void addToList(termSequence* head, termSequence* tail){
	termSequence* pointer = head;
	while(pointer->list!=NULL){
		/*puts(pointer->name);*/
		pointer=pointer->list;
	}
	pointer->list=tail;
}

char* termsequenceToStr(termSequence* tlist, int indent){
	char* result=NULL;
	
	while(tlist!=NULL){
		if(result!=NULL) {
			realloc(result,strlen(result)+strlen("\n")+strlen(tlist->name));
			strcat(result,"\n");
			strcat(result,indentStr(indent));
			strcat(result,tlist->name);
		}
		else {
			result=(char*)malloc(strlen(tlist->name));
			strcpy(result,tlist->name);
		}
		tlist=tlist->list;
	}
	
	return result;
}



void debugPrintTermsequence(termSequence* tlist){
	puts("bison: termSequence:");
	puts(termsequenceToStr(tlist,0)); 
}

formula* createFormula(fType t,char* name)
{
	struct formula* f=(formula*)malloc(sizeof(formula));
	f->type=t;
	f->name=name;
	f->list=NULL;
	f->leftFormula=NULL;
	f->rightFormula=NULL;
	return(f);
}

int main (int argc, char* argv[])
{
	#ifdef DEBUG
		puts("bison: Starting");
	#endif
	return yyparse();
}