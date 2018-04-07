  /* find predicate logic symbols */

%option noyywrap
%{
	#include "logic.tab.h"
	#include "structs.h"
%}

DIGIT    [0-9]
INTEGER {DIGIT}+

%%

[n-z]{INTEGER}?   {/* variable */
		   printf("lexer: variable: %s\n", yytext );
		   yylval.name=strdup(yytext);
		   return VARIABLE;
            }

[a-m]{INTEGER}?       {/* function name */
            printf("lexer: function name: %s\n",yytext );
			yylval.name=strdup(yytext);
			return FUNCTION;
            }
			
[A-Z]{INTEGER}?       {/* predicate */
            printf("lexer: predicate: %s\n",yytext );
			yylval.name=strdup(yytext);
			return PREDICATE;
            }
			
\& {
	printf("lexer: AND\n");
	return AND;
			}
\| {
	printf("lexer: OR\n");
	return OR;
			}
\~ {
	printf("lexer: NOT\n");
	return NOT;
			}
	
\-\> {
	printf("lexer: IMPLICATION\n");
	return IMPLICATION;
			}
\<\-\> {
	printf("lexer: EQUIVALENCE\n");
	return EQUIVALENCE;
			}
			
all {
	printf("lexer: ALL\n");
	return ALL;
			}

ex   {/* quantifier */
   printf("lexer: EXIST\n");
   return EXIST;
            }	

top   {/* top */
   printf("lexer: TOP\n");
   return TOP;
            }	
bottom   {/* bottom */
   printf("lexer: BOTTOM\n");
   return BOTTOM;
            }			

[ ] {/* space*/
   
		}			
\( {/*open parenthesis*/
	printf("lexer: parenthesis: %s\n",yytext);
	return OPENPAR;
}	
\) {/*close parenthesis*/
	printf("lexer: parenthesis: %s\n",yytext);
	return CLOSEPAR;
}		
\, {/*comma*/
	printf("lexer: comma: %s\n", yytext);
	return COMMA;
}
\n|. { 
        printf("lexer: warning, unexpected token: %s\n", yytext );
      }
%%
