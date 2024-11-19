#ifndef __COMMAND_H__
#define __COMMAND_H__ 1

#include <yrsh.h>

struct command
{
    char* name;
    char* args[20];

    size_t nargs;
};


struct command* command_new(const char* name);

int command_add_arg(struct command* cmd, const char* arg);

void command_free(struct command* cmd);

#endif // __COMMAND_H__
