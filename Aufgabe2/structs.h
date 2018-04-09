
typedef struct termSequence{
	char* name; /*variable or function*/
	struct termSequence* list;
}termSequence;

typedef enum {E_ATOM,E_AND,E_OR,E_NOT,E_IMPLICATION,E_EQUIVALENCE,E_ALL,E_EXIST,E_TOP,E_BOTTOM} fType;

typedef struct formula{
	fType type;
	char* name;
	termSequence* list;
	struct formula *leftFormula;
	struct formula *rightFormula;
}formula;