  /* find predicate logic symbols */

%option noyywrap
%{
	#include "logic.tab.h"
	#include "structs.h"
	//#define DEBUG
%}

DIGIT    [0-9]
INTEGER {DIGIT}+

%%

[n-z]{INTEGER}?   {/* variable */
			#ifdef DEBUG
				printf("lexer: variable: %s\n", yytext );
			#endif
			yylval.name=strdup(yytext);
			return VARIABLE;
            }

[a-m]{INTEGER}?       {/* function name */
			#ifdef DEBUG
				printf("lexer: function name: %s\n",yytext );
			#endif
			yylval.name=strdup(yytext);
			return FUNCTION;
            }
			
[A-Z]{INTEGER}?       {/* predicate */
			#ifdef DEBUG
				printf("lexer: predicate: %s\n",yytext );
			#endif
			yylval.name=strdup(yytext);
			return PREDICATE;
            }
			
\& {
	#ifdef DEBUG
		printf("lexer: AND\n");
	#endif
	return AND;
			}
\| {
	#ifdef DEBUG
		printf("lexer: OR\n");
	#endif
	return OR;
			}
\~ {
	#ifdef DEBUG
		printf("lexer: NOT\n");
	#endif
	return NOT;
			}
	
\-\> {
	#ifdef DEBUG
		printf("lexer: IMPLICATION\n");
	#endif
	return IMPLICATION;
			}
\<\-\> {
	#ifdef DEBUG
		printf("lexer: EQUIVALENCE\n");
	#endif
	return EQUIVALENCE;
			}
			
all {
	#ifdef DEBUG
		printf("lexer: ALL\n");
	#endif
	return ALL;
			}

ex   {/* quantifier */
	#ifdef DEBUG
		printf("lexer: EXIST\n");
	#endif
	return EXIST;
            }	

top   {/* top */
	#ifdef DEBUG
		printf("lexer: TOP\n");
	#endif
	return TOP;
            }	
bottom   {/* bottom */
	#ifdef DEBUG
		printf("lexer: BOTTOM\n");
	#endif
	return BOTTOM;
            }			

[ ] {/* space*/
   
		}			
\( {/*open parenthesis*/
	#ifdef DEBUG
		printf("lexer: parenthesis: %s\n",yytext);
	#endif
	return OPENPAR;
	}	
	
\) {/*close parenthesis*/
	#ifdef DEBUG
		printf("lexer: parenthesis: %s\n",yytext);
	#endif
	return CLOSEPAR;
	}		
	
\(\) { /*empty parentheses*/
	}

\, {/*comma*/
	#ifdef DEBUG
		printf("lexer: comma: %s\n", yytext);
	#endif
	return COMMA;
}
\n|. { 
        printf("lexer: warning, unexpected token: %s\n", yytext );
      }
%%
