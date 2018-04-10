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
	extern FILE* yyin;
	void addToList(termSequence* head, termSequence* tail);
	void debugPrintTermsequence(termSequence* tlist);
	void printFormula(formula* f,int indent);
	formula* createFormula(fType t,char* name);
	char* indentStr(int n);
	void printTermSequence(termSequence* tlist, int indent);
	void copyFormula(formula* target, formula* source);
   
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
					$<f>$=$<f>2;	
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
					t->args=NULL;
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
					func->args=NULL;
					$<list>$=func;
					#ifdef DEBUG
						puts("bison: term = function");  /*Constant, no paramter list*/
						puts(func->name);
					#endif
					}
		| FUNCTION OPENPAR termsequence CLOSEPAR {
					struct termSequence* func=(termSequence*)malloc(sizeof(termSequence));
					func->name=$<name>1;
					func->args=$<list>3;
					func->list=NULL;
					$<list>$=func;
					#ifdef DEBUG
						puts("bison: term = function(termsequence)");
						puts(func->name);
						debugPrintTermsequence(func->args);
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
						printTermSequence(atom->list,1);
					#endif
					}
		| term {
					struct formula* atom=createFormula(E_ATOM,$<list>1->name);
					atom->list=$<list>1->args; /* required if term = function(termSequence)*/
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
					printTermSequence(f->list,indent);
				}
				break;
			case E_AND:
				printFormula(f->leftFormula,indent);
				printFormula(f->rightFormula,indent);
				break;
			case E_ALL:
				if(f->list!=NULL)
					printTermSequence(f->list,indent);
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
					printTermSequence(f->list,indent);
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

void printTermSequence(termSequence* tlist, int indent){
	
	while(tlist!=NULL){
		//puts(tlist->name);
		printf("%s%s\n",indentStr(indent),tlist->name);
		if (tlist->args!=NULL){
			printTermSequence(tlist->args, indent+1);
		}
		tlist=tlist->list;
	}
}

void debugPrintTermsequence(termSequence* tlist){
	puts("termSequence:");
	printTermSequence(tlist,0); 
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

void normalizeStep1(formula* f){
	if (f!=NULL){
		normalizeStep1(f->leftFormula);
		normalizeStep1(f->rightFormula);
		switch (f->type){
			case E_EQUIVALENCE:
				f->type=E_OR;
				f->name=strdup("OR");
				formula* tmpLeft = f->leftFormula;
				formula* tmpRight = f->rightFormula;
				
				f->leftFormula=createFormula(E_AND,strdup("AND"));
				f->rightFormula=createFormula(E_AND,strdup("AND"));
				
				f->leftFormula->leftFormula=tmpLeft;
				f->leftFormula->rightFormula=tmpRight;
				
				f->rightFormula->leftFormula=createFormula(E_NOT, strdup("NOT"));
				f->rightFormula->leftFormula->leftFormula=tmpLeft;
				f->rightFormula->rightFormula=createFormula(E_NOT, strdup("NOT"));
				f->rightFormula->rightFormula->leftFormula=tmpRight;
	
				break;
			case E_IMPLICATION:
				f->type=E_OR;
				f->name=strdup("OR");
				formula* tmp= f->leftFormula;
				f->leftFormula=createFormula(E_NOT,strdup("NOT"));
				f->leftFormula->leftFormula=tmp;
				break;
		}
	}
}

int normalizeStep2(formula* f){
	int count=0;
	if (f!=NULL){
		count+=normalizeStep2(f->leftFormula);
		count+=normalizeStep2(f->rightFormula);
		if (f->type==E_NOT){
			formula* tmpLeft = f->leftFormula->leftFormula;
			formula* tmpRight = f->leftFormula->rightFormula;
			
			switch(f->leftFormula->type){
				case E_AND: //Case ~(x AND y) to ~x OR ~ y
					count++;
					f->type=E_OR;
					f->name=strdup("OR");
					f->leftFormula=createFormula(E_NOT,strdup("NOT"));
					f->leftFormula->leftFormula=tmpLeft;
					
					f->rightFormula=createFormula(E_NOT,strdup("NOT"));
					f->rightFormula->leftFormula=tmpRight;
					break;
				case E_OR: //Case ~(x OR y) to ~x AND ~ y
					count++;
					f->type=E_AND;
					f->name=strdup("AND");
					
					f->leftFormula=createFormula(E_NOT,strdup("NOT"));
					f->leftFormula->leftFormula=tmpLeft;
					
					f->rightFormula=createFormula(E_NOT,strdup("NOT"));
					f->rightFormula->leftFormula=tmpRight;
					break;
				case E_ALL: //Case ~all x y to ex x ~y
					count++;
					f->type=E_EXIST;
					f->name=strdup("EXIST");
					f->list=f->leftFormula->list;
					f->leftFormula->list=NULL;
					f->leftFormula->type=E_NOT;
					f->leftFormula->name=strdup("NOT");
					break;
				case E_EXIST: //Case ~ex x y to all x ~y
					count++;
					f->type=E_ALL;
					f->name=strdup("ALL");
					f->list=f->leftFormula->list;
					f->leftFormula->list=NULL;
					f->leftFormula->type=E_NOT;
					f->leftFormula->name=strdup("NOT");
					break;
			}
		}
	}
	return count;
}

void normalizeStep3(formula* f){
	if (f!=NULL){
		normalizeStep3(f->leftFormula);
		normalizeStep3(f->rightFormula);
		if ((f->type==E_NOT)&&(f->leftFormula->type==E_NOT)){
			copyFormula(f, f->leftFormula->leftFormula);
		}
	}
}

void copyFormula(formula* target, formula* source){
	target->name=source->name;
	target->type=source->type;
	target->rightFormula=source->rightFormula;
	target->leftFormula=source->leftFormula;
	target->list=source->list;
}
int main (int argc, char* argv[])
{
	++argv, --argc;
	if (argc>0)
		yyin = fopen(argv[0],"r");
	else
		yyin = stdin;
	
	#ifdef DEBUG
		puts("bison: Starting");
	#endif
	int result_int=yyparse();
	
	
	#ifdef DEBUG
		puts("bison: Ending");
	#endif
	normalizeStep1(result);
	while(normalizeStep2(result));
	normalizeStep3(result);
	puts("bison: normalized formula");
	
	printFormula(result,0);
	return result_int;
}