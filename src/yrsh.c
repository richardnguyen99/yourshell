#include <yrsh.h>

void
dumb_shell()
{
    char *line = NULL;

    for (;;)
    {
        line = readline("yrsh> ");
        if (line == NULL)
        {
            break;
        }

        if (strcmp(line, "exit") == 0)
        {
            free(line);
            break;
        }

        printf("%s\n", line);
        add_history(line);
    }
}
