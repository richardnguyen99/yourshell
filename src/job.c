#include <job.h>
#include <lex.yy.h>

extern char* line;
extern int yyparse(void);
extern void format_current_path(char* path, const size_t size);

YY_BUFFER_STATE buffer;

struct job*
    job_new()
{
    struct job* job = malloc(sizeof(struct job));
    if (job == NULL)
    {
        return NULL;
    }

    job->ncommands = 0;
    job->ncommands_executed = 0;

    job->infile = NULL;
    job->outfile = NULL;
    job->errfile = NULL;
    job->appendfile = NULL;

    job->background = 0;

    return job;
}

int
job_add_command(struct job* job, const char* command_name)
{
    if (job->ncommands >= MAX_COMMANDS)
    {
        return -1;
    }

    job->commands[job->ncommands] = command_new(command_name);

    if (job->commands[job->ncommands] == NULL)
    {
        return -1;
    }

    job->ncommands++;

    return 0;
}

int job_add_infile(struct job* job, const char* infile)
{
    if (job->infile != NULL)
    {
        free(job->infile);
    }

    job->infile = strdup(infile);

    if (job->infile == NULL)
    {
        return -1;
    }

    return 0;
}

int job_add_outfile(struct job* job, const char* outfile)
{
    if (job->outfile != NULL)
    {
        free(job->outfile);
    }

    job->outfile = strdup(outfile);

    if (job->outfile == NULL)
    {
        return -1;
    }

    return 0;
}

int job_add_errfile(struct job* job, const char* errfile)
{
    if (job->errfile != NULL)
    {
        free(job->errfile);
    }

    job->errfile = strdup(errfile);

    if (job->errfile == NULL)
    {
        return -1;
    }

    return 0;
}

int job_add_appendfile(struct job* job, const char* appendfile)
{
    if (job->appendfile != NULL)
    {
        free(job->appendfile);
    }

    job->appendfile = strdup(appendfile);

    if (job->appendfile == NULL)
    {
        return -1;
    }

    return 0;
}

int job_execute(struct job* job)
{
    int fd[2];
    int pid, prev_fd = 0;

    for (size_t i = 0; i < job->ncommands; ++i)
    {
        /* Check if the command is cd */
        if (strcmp(job->commands[i]->name, "cd") == 0)
        {
            if (job_change_directory(job->commands[i]->args[1]) == -1)
            {
                perror("cd");
                return -1;
            }
        }


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
        }
        else {
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
            return -1;
        }
    }

    return 0;
}

int job_change_directory(const char* path)
{
    char current_path[4096];
    memset(current_path, 0, sizeof(current_path));

    if (getcwd(current_path, sizeof(current_path)) == NULL)
    {
        return -1;
    }

    /* check if arg is ~ */
    if (strcmp(path, "~") == 0)
    {
        if (chdir(getenv("HOME")) == -1)
            return -1;

        return 0;
    }

    /* Check if arg is - */
    if (strcmp(path, "-") == 0)
    {
        char* oldpwd = getenv("OLDPWD");

        if (oldpwd == NULL)
        {
            fprintf(stderr, "OLDPWD not set\n");
            return -1;
        }

        if (chdir(oldpwd) == -1)
        {
            return -1;
        }

        return 0;
    }

    if (chdir(path) == -1)
    {
        return -1;
    }

    if (setenv("OLDPWD", current_path, 1) == -1)
    {
        return -1;
    }

    return 0;
}

void job_prompt(struct job** job)
{
    if (*job != NULL)
    {
        job_free(*job);
        *job = NULL;
    }

    *job = job_new();
    if (job == NULL)
        exit(EXIT_FAILURE);

    char path[4096];
    memset(path, 0, sizeof(path));

    format_current_path(getcwd(path, sizeof(path)), sizeof(path));

    char prompt[4096];
    memset(prompt, 0, sizeof(prompt));
    snprintf(prompt, sizeof(prompt), GREEN "yrsh" RESET "@" GREEN "%s" RESET "> ", path);

    line = readline(prompt);
    if (line == NULL)
        exit(EXIT_FAILURE);

    if (strlen(line) == 0)
    {
        free(line);
        job_prompt(job);
    }

    /* Create a new string with new line for lexer only.
       Meanwhile, readline does not need new line characters at the end of
       the string because it will mess up the history.
     */

    char* line_with_newl = malloc(strlen(line) + 2);

    if (line_with_newl == NULL)
        exit(EXIT_FAILURE);

    strcpy(line_with_newl, line);
    strcat(line_with_newl, "\n");

    /* Switch lexer to use buffer instead of stdin */
    buffer = yy_scan_string(line_with_newl);
    yy_switch_to_buffer(buffer);

    printf(CYAN "Job@%p begins" RESET "\n", (void*)*job);

    add_history(line);
    free(line);
    free(line_with_newl);
    line = NULL;

    int status = yyparse();

    if (status == 1)
        fprintf(stderr, "Syntax error\n");
}

void
job_free(struct job* job)
{
    for (size_t i = 0; i < job->ncommands; i++)
    {
        command_free(job->commands[i]);
        job->commands[i] = NULL;
    }

    if (job->infile != NULL)
        free(job->infile);

    if (job->outfile != NULL)
        free(job->outfile);

    if (job->errfile != NULL)
        free(job->errfile);

    if (job->appendfile != NULL)
        free(job->appendfile);

    job->ncommands = 0;
    job->ncommands_executed = 0;

    job->infile = NULL;
    job->outfile = NULL;
    job->errfile = NULL;
    job->appendfile = NULL;

    job->background = 0;

    free(job);
}
