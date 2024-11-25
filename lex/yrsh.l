%{
#include <string.h>
#include <y.tab.h>
%}

%%
\n {
    if (yylval.string_val != NULL) {
        free(yylval.string_val);
        yylval.string_val = NULL;
    }

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

"1>" {
    return REDIRECT;
}

"2>" {
    return ERRORREDIRECT;
}

"<" {
    return INPUT;
}

[^ \t\n&<>|]+  {
    if (yylval.string_val != NULL) {
        free(yylval.string_val);
        yylval.string_val = NULL;
    }

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
