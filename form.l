%{
#include "form.tab.h"
#include <string.h>
#include <stdlib.h>

%}

%%

\n              { yylineno++; }
[ \t\r]+        ;

form            { return FORM; }
section         { return SECTION; }
field           { return FIELD; }
required        { return REQUIRED; }

pattern         { return PATTERN; }
default         { return DEFAULT; }
min             { return MIN; }
max             { return MAX; }
rows            { return ROWS; }
cols            { return COLS; }
options         { return OPTIONS; }
accept          { return ACCEPT; }

true|false      { yylval.str = strdup(yytext); return STRING; }
\"[^\"]*\"      { yylval.str = strdup(yytext); return STRING; }
\[[^]]*\]       { yylval.str = strdup(yytext); return STRING; }
[0-9]+          { yylval.str = strdup(yytext); return STRING; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }

=               { return EQUAL; }
:               { return COLON; }
;               { return SEMICOLON; }
\{              { return LBRACE; }
\}              { return RBRACE; }

.               { return yytext[0]; }

%%

int yywrap() { return 1; }
