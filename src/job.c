#include <job.h>

struct job*
    job_new()
{
    struct job* job = malloc(sizeof(struct job));
    if (job == NULL)
    {
        return NULL;
    }

    job->ncommands = 0;
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
    job->infile = NULL;
    job->outfile = NULL;
    job->errfile = NULL;
    job->appendfile = NULL;
    job->background = 0;

    free(job);
}
