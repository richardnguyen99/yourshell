%{
#include <stdio.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif
    int yylex();
    void yyerror(const char *s);
#ifdef __cplusplus
}
#endif

#define yylex yylex
%}

%token <string_val> WORD
%token NOTOKEN GREAT NEWLINE AMPERSAND PIPE APPEND SMALL AMPERSANDAPPEND LESS CD AND OR SEMICOLON REDIRECT INPUT

%union {
    char *string_val;
}

%%

goals: /* empty */
    | goals NEWLINE
    ;

%%

void yyerror(const char *s) {
    // Print error message
    fprintf(stderr, "%s", s);
}
