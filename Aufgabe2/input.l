  /* find predicate logic symbols */

%option noyywrap


%{
	#include "logic.tab.h";
%}

DIGIT    [0-9]
INTEGER {DIGIT}+

%%

[n-z]{INTEGER}?   {/* variable */
   printf( "variable: %s\n", yytext );
   return VARIABLE;
            }

[a-m]{INTEGER}?       {/* function name */
            printf( "function name: %s",yytext );
			return FUNCTION;
            }
			
[A-Z]{INTEGER}?       {/* predicate */
            printf( "predicate: %s\n",yytext );
			return PREDICATE
            }
			
\& {
	printf("AND");
	return AND;
			}
\| {
	printf("OR");
	return OR;
			}
\~ {
	printf("NOT");
	return NOT;
			}
(\-\>){
	printf("IMPLICATION");
	return IMPLICATION;
			}
(\<\-\>){
	printf("EQUIVALENCE");
	return EQUIVALENCE;
			}
			
all{
	printf("ALL");
	return ALL;
			}

ex   {/* quantifier */
   printf( "EXIST");
   return EXIST;
            }
top   {/* top */
   printf( "TOP");
   return TOP;
            }	
bottom   {/* bottom */
   printf( "BOTTOM");
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

int main( int argc, char **argv )       
{
   ++argv, --argc;  /* skip over program name */
   if ( argc > 0 )
      yyin = fopen( argv[0], "r" );
   else
      yyin = stdin;
   
   yylex();
   
   printf("\nProgram finished");
}