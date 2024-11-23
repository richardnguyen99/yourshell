%{
#include <yrsh.h>
#include <command.h>
#include <job.h>
#include <lex.yy.h>

#ifdef __cplusplus
extern "C" {
#endif
    int yylex();
    void yyerror(const char *s);
#ifdef __cplusplus
}
#endif

#define yylex yylex

extern YY_BUFFER_STATE buffer;
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
    | SHNEWLINE {
        yy_delete_buffer(buffer);
        job_free(job);
        job = NULL;
        job_prompt(&job);
    }
    | error SHNEWLINE { yyerrok; }
    ;

complex_command:
    command_and_args piped_list iomodifier_list ampersandmodifier SHNEWLINE {
#if DEBUG
        printf("command_and_args piped_list iomodifier_list ampersandmodifier SHNEWLINE\n");
#endif
    }
    | command_and_args iomodifier_list ampersandmodifier SHNEWLINE {
#if DEBUG
        printf("command_and_args iomodifier_list ampersandmodifier SHNEWLINE\n");
#endif
    }
    | command_and_args piped_list iomodifier_list SHNEWLINE {
        job_execute(job);

        if (yylval.string_val != NULL)
        {
            free(yylval.string_val);
            yylval.string_val = NULL;
        }

        job_free(job);
        job = NULL;

        yy_delete_buffer(buffer);
        job_prompt(&job);
    }
    | command_and_args iomodifier_list SHNEWLINE {
#if DEBUG
        printf("command_and_args iomodifier_list SHNEWLINE\n");
#endif
    }
    ;

simple_command:
    command_and_args iomodifier_opt SHNEWLINE {
#if DEBUG
        printf("simple_command\n");

        job_execute(job);

        if (yylval.string_val != NULL)
        {
            free(yylval.string_val);
            yylval.string_val = NULL;
        }

        job_free(job);
        job = NULL;

        yy_delete_buffer(buffer);
        job_prompt(&job);
#endif
    }
    ;

piped_list:
    piped_list piped_command 
    |
    ;

piped_command:
    PIPE command_and_args {
        job->commands[job->ncommands - 2]->is_piped = 1;
#if DEBUG
        printf(MAGENTA "Command@%p" RESET " marked as piped\n", (void*)job->commands[job->ncommands - 2]);
#endif
    }
    ;

command_and_args:
    command_word arg_list 
    ;

arg_list:
    arg_list argument
    |
    ;

argument:
    WORD {
        command_add_arg(job->commands[job->ncommands - 1], $1);
#if DEBUG
        printf(GREEN "Command@%p" RESET " argument being added (arg: %s)\n", (void*)job->commands[job->ncommands - 1], job->commands[job->ncommands - 1]->args[job->commands[job->ncommands - 1]->nargs - 1]);
#endif
    }
    ;

command_word:
    WORD {
        job_add_command(job, $1);
#if DEBUG
        printf(YELLOW "Command@%p" RESET " being added (cmd: %s)\n", (void*)job->commands[job->ncommands - 1], job->commands[job->ncommands - 1]->name);
#endif
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
        job_add_infile(job, $2);
#if DEBUG
        printf(BLUE "Job@%p I/O INPUT MODIFIER" RESET " being added (file: %s)\n", (void*)job, $2);
#endif
    }
    ;

ampersandappendmodifier:
    AMPERSANDAPPEND WORD {
#if DEBUG
        printf("ampersandappendmodifier: &>> %s\n", $2);
#endif
    }

iomodifier_opt:
    REDIRECT WORD {
        job_add_outfile(job, $2);
#if DEBUG
        printf(BLUE "Job@%p I/O REDIRECT MODIFIER" RESET " being added (file: %s)\n", (void*)job, $2);
#endif
    }
    ;

appendmodifier:
    APPEND WORD {
        // Insert append modifier into the current command
#if DEBUG
        printf("appendmodifier: >> %s\n", $2);
#endif
    }
    ;

ampersandmodifier:
    AMPERSAND {
        // Set background flag in the current command
#if DEBUG
        printf("ampersandmodifier (run in background): &\n");
#endif
    }
    ;

%%

void yyerror(const char *s) {
    // Print error message
    fprintf(stderr, "%s\n", s);
}
