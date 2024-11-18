#include <yrsh.h>
#include <lex.yy.h>

extern int yyparse(void);

char* line;


int
main()
{
    for (;;)
    {
        line = readline("yrsh> ");

        if (line == NULL)
            exit(EXIT_FAILURE);

        fflush(stdout);

        line = realloc(line, strlen(line) + 2);

        if (line == NULL)
            exit(EXIT_FAILURE);

        strcat(line, "\n");

        /* Switch lexer to use buffer instead of stdin */
        YY_BUFFER_STATE buffer = yy_scan_string(line);
        yy_switch_to_buffer(buffer);
        free(line);

        int status = yyparse();

        if (status == 1)
            fprintf(stderr, "Syntax error\n");

        yy_delete_buffer(buffer);
    }

    return 0;
}
