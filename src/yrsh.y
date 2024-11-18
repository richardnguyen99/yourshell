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

goals:
    commands
    ;

commands:
    command
    | commands command
    ;

command:
    complex_command
    | simple_command
    | NEWLINE 
    | error NEWLINE { yyerrok; }
    ;

complex_command:
    command_and_args piped_list iomodifier_list ampersandmodifier NEWLINE {
        printf("command_and_args piped_list iomodifier_list ampersandmodifier NEWLINE\n");
    }
    | command_and_args iomodifier_list ampersandmodifier NEWLINE {
        printf("command_and_args iomodifier_list ampersandmodifier NEWLINE\n");
    }
    | command_and_args piped_list iomodifier_list NEWLINE {
        printf("command_and_args piped_list iomodifier_list NEWLINE\n");
    }
    | command_and_args iomodifier_list NEWLINE {
        printf("command_and_args iomodifier_list NEWLINE\n");
    }
    ;

simple_command:
    command_and_args iomodifier_opt NEWLINE {
        printf("simple_command\n");
    }
    ;

piped_list:
    piped_list piped_command
    |
    ;

piped_command:
    PIPE command_and_args {
        printf("piped_command\n");
    }
    ;

command_and_args:
    command_word arg_list {
        printf("command_and_args\n");
    }
    ;

arg_list:
    arg_list argument
    |
    ;

argument:
    WORD {
        printf("argument: %s\n", $1);
    }
    ;

command_word:
    WORD {
        printf("command_word: %s\n", $1);
    }
    ;

iomodifier_list:
    iomodifier_list iomodifier
    |
    ;

iomodifier:
    iomodifier_opt
    | ampersandappendmodifier
    | iomodifier_ipt
    | appendmodifier
    ;

iomodifier_ipt:
    INPUT WORD {
        printf("iomodifier_ipt: < %s\n", $2);
    }
    ;

ampersandappendmodifier:
    AMPERSANDAPPEND WORD {
        printf("ampersandappendmodifier: &>> %s\n", $2);
    }

iomodifier_opt:
    REDIRECT WORD {
        printf("iomodifier_opt output: > %s\n", $2);
    }
    ;

appendmodifier:
    APPEND WORD {
        // Insert append modifier into the current command
        printf("appendmodifier: >> %s\n", $2);
    }
    ;

ampersandmodifier:
    AMPERSAND {
        // Set background flag in the current command
        printf("ampersandmodifier (run in background): &\n");
    }
    ;

%%

void yyerror(const char *s) {
    // Print error message
    fprintf(stderr, "%s\n", s);
}
