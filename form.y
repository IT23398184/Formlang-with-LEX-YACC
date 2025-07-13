%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;

char* concat(const char* s1, const char* s2);
char* create_field(char* name, char* type, char* attrs);
char* strip_quotes(char* str); // Defined in html_generator.c

char* current_field_type = NULL;

void yyerror(const char *s) {
    extern char *yytext;
    fprintf(stderr, "Syntax error near '%s' at line %d\n", yytext, yylineno);

    if (strcmp(yytext, "}") == 0 || strcmp(yytext, "field") == 0) {
        fprintf(stderr, "Hint: Did you forget a semicolon before this?\n");
    }
    if (strchr(yytext, '(') || strchr(yytext, '=')) {
        fprintf(stderr, "Hint: Use square brackets for options like: options=[\"A\",\"B\"]\n");
    }

    exit(1);
}

int yylex(void);
char field_attrs[1024];

void reset_attributes() {
    field_attrs[0] = '\0';
}
%}

%union {
    char* str;
}

%token FORM SECTION FIELD REQUIRED
%token PATTERN DEFAULT MIN MAX ROWS COLS OPTIONS ACCEPT
%token <str> IDENTIFIER STRING
%token COLON SEMICOLON LBRACE RBRACE EQUAL

%type <str> program section_list section field_list field field_attributes

%%

program:
    FORM IDENTIFIER LBRACE section_list RBRACE {
printf("<!DOCTYPE html>\n<html>\n<head>\n<meta charset=\"UTF-8\">\n<link rel=\"stylesheet\" href=\"style.css\">\n<title>Form Output</title>\n</head>\n<body>\n<form>\n%s<div style=\"margin-top:20px;\"><button type=\"submit\">Submit</button></div>\n</form>\n</body>\n</html>\n", $4);
    }
;

section_list:
    section_list section { $$ = concat($1, $2); }
  | section              { $$ = $1; }
;

section:
    SECTION IDENTIFIER LBRACE field_list RBRACE {
        $$ = $4;
    }
;

field_list:
    field_list field { $$ = concat($1, $2); }
  | field           { $$ = $1; }
;

field:
    FIELD IDENTIFIER COLON IDENTIFIER {
        current_field_type = $4;
    }
    field_attributes SEMICOLON {
        $$ = create_field($2, current_field_type, field_attrs);
        reset_attributes();
    }
;

field_attributes:
    field_attributes attribute { }
  | /* empty */ { }
;

attribute:
    REQUIRED {
        strcat(field_attrs, " required");
    }
  | OPTIONS EQUAL STRING {
        if (strcmp(current_field_type, "dropdown") != 0 &&
            strcmp(current_field_type, "radio") != 0) {
            fprintf(stderr, "Error: 'options' is invalid for field type '%s' at line %d\n", current_field_type, yylineno);
            exit(1);
        }
        strcat(field_attrs, " data-options=");
        strcat(field_attrs, $3);
    }
  | ROWS EQUAL STRING {
        if (strcmp(current_field_type, "textarea") != 0) {
            fprintf(stderr, "Error: 'rows' is only valid for 'textarea' at line %d\n", yylineno);
            exit(1);
        }
        strcat(field_attrs, " rows=");
        strcat(field_attrs, $3);
        strcat(field_attrs, "\"");
    }
  | COLS EQUAL STRING {
        if (strcmp(current_field_type, "textarea") != 0) {
            fprintf(stderr, "Error: 'cols' is only valid for 'textarea' at line %d\n", yylineno);
            exit(1);
        }
        strcat(field_attrs, " cols=");
        strcat(field_attrs, $3);
        strcat(field_attrs, "\"");
    }
  | DEFAULT EQUAL STRING {
        strcat(field_attrs, " value=\"");
        strcat(field_attrs, strip_quotes($3));
        strcat(field_attrs, "\"");
    }
  | PATTERN EQUAL STRING {
        strcat(field_attrs, " pattern=\"");
        strcat(field_attrs, strip_quotes($3));
        strcat(field_attrs, "\"");
    }
  | MIN EQUAL STRING {
        strcat(field_attrs, " min=\"");
        strcat(field_attrs, $3);
        strcat(field_attrs, "\"");
    }
  | MAX EQUAL STRING {
        strcat(field_attrs, " max=\"");
        strcat(field_attrs, $3);
        strcat(field_attrs, "\"");
    }
  | ACCEPT EQUAL STRING {
        if (strcmp(current_field_type, "file") != 0) {
            fprintf(stderr, "Error: 'accept' is only valid for 'file' inputs at line %d\n", yylineno);
            exit(1);
        }
        strcat(field_attrs, " accept=");
        strcat(field_attrs, $3);
    }
;

%%

int main() {
    return yyparse();
}
