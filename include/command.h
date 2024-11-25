#ifndef __COMMAND_H__
#define __COMMAND_H__ 1

#include <yrsh.h>

#define MAX_ARGS 20

/* struct that represents an execution of a command */
struct command
{
    /* command name such as `ls`, `cat`, `wc` or any executables */
    char *name;

    /* arguments and options that will be passed to the commmand */
    char *args[MAX_ARGS];

    /* Flag to either print the output to STDOUT or pass output to other process
     STDIN */
    int is_piped;

    /* Number of arguments */
    size_t nargs;
};

/* construct a new command buffer. The function returns `NULL` if there is an
allocating error. */
struct command *
command_new(const char *name);

/* add arguments to an existing command buffer. The function returns -1 if
either there is no space for new arguments or there is an allocating error.  */
int
command_add_arg(struct command *cmd, const char *arg);

/* free the command buffer */
void
command_free(struct command *cmd);

#endif // __COMMAND_H__
