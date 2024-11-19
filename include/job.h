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

int job_add_infile(struct job* job, const char* infile);
int job_add_outfile(struct job* job, const char* outfile);
int job_add_errfile(struct job* job, const char* errfile);
int job_add_appendfile(struct job* job, const char* appendfile);

void
job_free(struct job* job);


extern struct job* job;

#endif // __JOB_H__
