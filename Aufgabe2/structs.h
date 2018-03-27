typedef struct term{
		char* varFunc; /*variable or function*/
	}term;
	
typedef struct termList{
	term t;
	struct termList *list;
}termList;
enum {atom,and,or,not,implication,equivalence,all,exist,top,bottom};
typedef struct formula{
	int type;
	char* predicate;
	termList list;
	struct formula *leftFormula;
	struct formula *rightFormula;
	char* variable;
}formula;