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

        int fd[2];
        int pid, prev_fd = 0;

        for (size_t i = 0; i < job->ncommands; ++i)
        {

            if (i < job->ncommands - 1)
            {
                if (pipe(fd) == -1)
                {
                    perror("pipe");
                    exit(EXIT_FAILURE);
                }
            }

            pid = fork();

            if (pid == -1)
            {
                perror("fork");
                exit(EXIT_FAILURE);
            }

            /* Child process */
            if (pid == 0) 
            {
                if (job->ncommands > 1)
                {
                    /* First command in the job */
                    if (i == 0)
                    {
                        /* Redirect the write end of the pipe to standard output
                           Data written to the write end of pipe will be buffered
                           until the read end of the pipe is read.  
                         */

                        if (dup2(fd[1], STDOUT_FILENO) == -1)
                        {
                            perror("dup2");
                            exit(EXIT_FAILURE);
                        }

                        /* Close the read end of the pipe */

                        if (close(fd[0]) == -1)
                        {
                            perror("close");
                            exit(EXIT_FAILURE);
                        }
                    }
                    /* Last command in the job */
                    else if (i == job->ncommands - 1)
                    {
                        if (dup2(prev_fd, STDIN_FILENO) == -1)
                        {
                            perror("dup2");
                            exit(EXIT_FAILURE);
                        }
                    }
                    /* Middle command in the job */
                    else
                    {
                        if (dup2(prev_fd, STDIN_FILENO) == -1)
                        {
                            perror("dup2");
                            exit(EXIT_FAILURE);
                        }

                        if (dup2(fd[1], STDOUT_FILENO) == -1)
                        {
                            perror("dup2");
                            exit(EXIT_FAILURE);
                        }

                        if (close(prev_fd) == -1)
                        {
                            perror("close");
                            exit(EXIT_FAILURE);
                        }

                        if (close(fd[0]) == -1)
                        {
                            perror("close");
                            exit(EXIT_FAILURE);
                        }
                    }
                }

                execvp(job->commands[i]->name, job->commands[i]->args);

                // Maybe handle some error if the code reaches here
            } else {
                printf("Child process %d created\n", pid);
                printf(RED "Command@%p" RESET " being executed (cmd: %s, args: [", (void*)job->commands[i], job->commands[i]->name);

                for (size_t j = 0; j < job->commands[i]->nargs; ++j)
                {
                    printf("%s", job->commands[i]->args[j]);

                    if (j < job->commands[i]->nargs - 1)
                    {
                        printf(",");
                    }
                }

                printf("])\n");
                 
                if (job->ncommands > 1) 
                {
                    if (i < job->ncommands - 1)
                    {
                        if (close(fd[1]) == -1)
                        {
                            perror("close");
                            exit(EXIT_FAILURE);
                        }
                    }

                    prev_fd = fd[0];
                }
            }

        }


        if (yylval.string_val != NULL)
        {
            free(yylval.string_val);
            yylval.string_val = NULL;
        }

        int status;
        pid_t wpid;

        while ((wpid = waitpid(-1, &status, 0)) > 0)
        {
            if (WIFEXITED(status))
            {
            }
            else
            {
                printf("Child process %d terminated abnormally\n", wpid);
                exit(EXIT_FAILURE);
            }
        }

        job_prompt(&job);

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
        job->commands[job->ncommands - 2]->is_piped = 1;
        printf(MAGENTA "Command@%p" RESET " marked as piped\n", (void*)job->commands[job->ncommands - 2]);
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
        printf(GREEN "Command@%p" RESET " argument being added (arg: %s)\n", (void*)job->commands[job->ncommands - 1], job->commands[job->ncommands - 1]->args[job->commands[job->ncommands - 1]->nargs - 1]);
    }
    ;

command_word:
    WORD {
        job_add_command(job, $1);
        printf(YELLOW "Command@%p" RESET " being added (cmd: %s)\n", (void*)job->commands[job->ncommands - 1], job->commands[job->ncommands - 1]->name);
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
        printf(BLUE "Job@%p I/O INPUT MODIFIER" RESET " being added (file: %s)\n", (void*)job, $2);
    }
    ;

ampersandappendmodifier:
    AMPERSANDAPPEND WORD {
        printf("ampersandappendmodifier: &>> %s\n", $2);
    }

iomodifier_opt:
    REDIRECT WORD {
        job_add_outfile(job, $2);
        printf(BLUE "Job@%p I/O REDIRECT MODIFIER" RESET " being added (file: %s)\n", (void*)job, $2);
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
