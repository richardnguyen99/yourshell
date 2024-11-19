#include <yrsh.h>
#include <job.h>
#include <lex.yy.h>

extern int yyparse(void);

char* line;
struct job* job;

int
main()
{
    job = job_new();

    for (;;)
    {
        line = readline("yrsh> ");

        if (line == NULL)
            exit(EXIT_FAILURE);

        fflush(stdout);

        char* line_with_newl = malloc(strlen(line) + 2);

        if (line_with_newl == NULL)
            exit(EXIT_FAILURE);

        strcpy(line_with_newl, line);
        strcat(line_with_newl, "\n");

        /* Switch lexer to use buffer instead of stdin */
        YY_BUFFER_STATE buffer = yy_scan_string(line_with_newl);
        yy_switch_to_buffer(buffer);

        printf(CYAN "Job@%p begins" RESET "\n", (void*)job);

        int status = yyparse();

        if (status == 1)
            fprintf(stderr, "Syntax error\n");

        add_history(line);

        yy_delete_buffer(buffer);
        job_free(job);
        free(line);
        free(line_with_newl);
    }

    free(job);
    job = NULL;

    return 0;
}
