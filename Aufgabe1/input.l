  /* find predicate logic symbols */

%option noyywrap


%{
   int    intval   = 0;
   double floatval = 0.0;
%}

DIGIT    [0-9]
INTEGER {DIGIT}+

%%
/* todo: one rule per token*/


[n-z]{INTEGER}?   {/* Variable */
   printf( "variable: %s\n", yytext );
            }

[a-m]{INTEGER}?       {/* function name */
            printf( "function name: %s",yytext );
            }
			
[A-Z]{INTEGER}?       {/* predicate */
            printf( "predicate: %s\n",yytext );
            }
			
\&|\||\~|(\-\>)|(\<\-\>) {/* connective */
   printf( "connective: %s\n", yytext );
            }
			
all|ex   {/* quantifier */
   printf( "quantifier: %s\n", yytext );
            }
			
top|bottom  {/* bool constant */
   printf( "bool constant: %s\n", yytext );
            }
[ ] {/* space*/
   printf( "space: \"%s\"\n",yytext);
		}			
\(|\) {/*parenthesis*/
	printf("parenthesis: %s\n",yytext);
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