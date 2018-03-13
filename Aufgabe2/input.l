  /* find predicate logic symbols */

%option noyywrap
%{
	#include "logic.tab.h"
%}

DIGIT    [0-9]
INTEGER {DIGIT}+

%%

[n-z]{INTEGER}?   {/* variable */
   printf( "variable: %s\n", yytext );
   return VARIABLE;
            }

[a-m]{INTEGER}?       {/* function name */
            printf( "function name: %s\n",yytext );
			return FUNCTION;
            }
			
[A-Z]{INTEGER}?       {/* predicate */
            printf( "predicate: %s\n",yytext );
			return PREDICATE;
            }
			
\& {
	printf("AND\n");
	return AND;
			}
\| {
	printf("OR\n");
	return OR;
			}
\~ {
	printf("NOT\n");
	return NOT;
			}
	
\-\> {
	printf("IMPLICATION\n");
	return IMPLICATION;
			}
\<\-\> {
	printf("EQUIVALENCE\n");
	return EQUIVALENCE;
			}
			
all {
	printf("ALL\n");
	return ALL;
			}

ex   {/* quantifier */
   printf( "EXIST\n");
   return EXIST;
            }	

top   {/* top */
   printf( "TOP\n");
   return TOP;
            }	
bottom   {/* bottom */
   printf( "BOTTOM\n");
   return BOTTOM;
            }			

[ ] {/* space*/
   printf( "space: \"%s\"\n",yytext);
		}			
\( {/*open parenthesis*/
	printf("parenthesis: %s\n",yytext);
	return OPENPAR;
}	
\) {/*close parenthesis*/
	printf("parenthesis: %s\n",yytext);
	return CLOSEPAR;
}		
\, {/*comma*/
	printf("comma: %s\n", yytext);
}
\n|. { 
        printf( "warning, unexpected token: %s\n", yytext );
      }
%%
