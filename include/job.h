#ifndef __JOB_H__
#define __JOB_H__ 1

#include <command.h>
#include <yrsh.h>

#define MAX_COMMANDS 20

struct job
{
    struct command* commands[MAX_COMMANDS];
    size_t ncommands;

    char* infile;
    char* outfile;
    char* errfile;
    char* appendfile;
    int background;
};

struct job* job_new();

int job_add_command(struct job* job, const char* command_name);

void
job_free(struct job* job);

extern struct job* job;

#endif // __JOB_H__