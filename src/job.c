#include <job.h>
#include <lex.yy.h>

extern char* line;
extern int yyparse(void);
extern void format_current_path(char* path, const size_t size);

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
    if (job->ncommands == 0)
    {
        return 0;
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
    YY_BUFFER_STATE buffer = yy_scan_string(line_with_newl);
    yy_switch_to_buffer(buffer);

    printf(CYAN "Job@%p begins" RESET "\n", (void*)*job);

    int status = yyparse();

    if (status == 1)
        fprintf(stderr, "Syntax error\n");

    add_history(line);

    yy_delete_buffer(buffer);
    free(line);
    free(line_with_newl);
    job_free(*job);

    *job = NULL;
    line = NULL;
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
