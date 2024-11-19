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

void
job_free(struct job* job)
{
    for (size_t i = 0; i < job->ncommands; i++)
    {
        command_free(job->commands[i]);
        job->commands[i] = NULL;
    }

    job->ncommands = 0;
    job->infile = NULL;
    job->outfile = NULL;
    job->errfile = NULL;
    job->appendfile = NULL;
    job->background = 0;
}
