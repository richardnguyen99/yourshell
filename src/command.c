#include <command.h>

struct command* command_new(const char* name)
{
    struct command* cmd = calloc(1, sizeof(struct command));
    if (cmd == NULL)
    {
        return NULL;
    }

    cmd->name = strdup(name);

    if (cmd->name == NULL)
    {
        free(cmd);
        return NULL;
    }

    /* execvp(command, *args) while args[0]  should be the command */

    cmd->args[0] = strdup(name);

    if (cmd->args[0] == NULL)
    {
        free(cmd->name);
        free(cmd);
        return NULL;
    }

    cmd->nargs = 1;

    return cmd;
}

int command_add_arg(struct command* cmd, const char* arg)
{
    if (cmd->nargs >= MAX_ARGS)
    {
        return -1;
    }

    cmd->args[cmd->nargs] = strdup(arg);

    if (cmd->args[cmd->nargs] == NULL)
    {
        return -1;
    }

    cmd->nargs++;

    return 0;
}

void command_free(struct command* cmd)
{
    free(cmd->name);

    for (size_t i = 0; i < cmd->nargs; i++)
    {
        free(cmd->args[i]);
        cmd->args[i] = NULL;
    }

    cmd->name = NULL;
    cmd->nargs = 0;

    free(cmd);
}
