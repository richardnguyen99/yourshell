%{
#include <string.h>
#include <y.tab.h>
%}

%%
\n {
    yylval.string_val = strdup(yytext);
    return SHNEWLINE;
}

[ \t]+ {
    // Ignore whitespace
}

"&" {
    return AMPERSAND;
}

"|" {
    return PIPE;
}

"&&" {
    return AND;
}

"&>>" {
    return AMPERSANDAPPEND;
}

"||" {
    return OR;
}

";" {
    return SEMICOLON;
}

">>" {
    return APPEND;
}

">" {
    return REDIRECT;
}

"<" {
    return INPUT;
}

[^ \t\n&<>|]+  {
    /* Allow any character except for special characters */
    yylval.string_val = strdup(yytext);
    return WORD;
}

. {
    /* Invalid character in input */
    return NOTOKEN;
}



%%
int yywrap() {
    return 1;
}