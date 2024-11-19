%{
#include <yrsh.h>
#include <command.h>
#include <job.h>

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
%token NOTOKEN GREAT SHNEWLINE AMPERSAND PIPE APPEND SMALL AMPERSANDAPPEND AND OR SEMICOLON REDIRECT INPUT

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
    | SHNEWLINE 
    | error SHNEWLINE { yyerrok; }
    ;

complex_command:
    command_and_args piped_list iomodifier_list ampersandmodifier SHNEWLINE {
        printf("command_and_args piped_list iomodifier_list ampersandmodifier SHNEWLINE\n");
    }
    | command_and_args iomodifier_list ampersandmodifier SHNEWLINE {
        printf("command_and_args iomodifier_list ampersandmodifier SHNEWLINE\n");
    }
    | command_and_args piped_list iomodifier_list SHNEWLINE {
        printf("command_and_args piped_list iomodifier_list SHNEWLINE\n");

        for (size_t i = 0; i < job->ncommands; ++i)
        {
            printf(BLUE "Command@%p" RESET " being executed (cmd: %s, args: [", (void*)job->commands[i], job->commands[i]->name);

            for (size_t j = 0; j < job->commands[i]->nargs; ++j)
            {
                printf("%s", job->commands[i]->args[j]);

                if (j < job->commands[i]->nargs - 1)
                {
                    printf(",");
                }
            }

            printf("])\n");
        }
    }
    | command_and_args iomodifier_list SHNEWLINE {
        printf("command_and_args iomodifier_list SHNEWLINE\n");
    }
    ;

simple_command:
    command_and_args iomodifier_opt SHNEWLINE {
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
        command_add_arg(job->commands[job->ncommands - 1], $1);
    }
    ;

command_word:
    WORD {
        printf("command_word: %s\n", $1);
        job_add_command(job, $1);
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
