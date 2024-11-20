#include <yrsh.h>
#include <job.h>
#include <lex.yy.h>

extern int yyparse(void);

char* line;
struct job* job;

void handle_ctrl_c(int sig)
{

    if (job != NULL)
    {
        job_free(job);
        job = NULL;
    }

    if (line != NULL)
    {
        free(line);
        line = NULL;
    }

    printf("\nExited yourshell (signo: %d)\n", sig);
    fflush(stdout);

    exit(0);
}

void handle_sig_child(int sig)
{
    int status;
    pid_t pid;

    while ((pid = waitpid(-1, &status, WNOHANG)) > 0)
    {
        if (WIFEXITED(status))
        {
            printf("Process %d exited with status %d (signo: %d)\n", pid, WEXITSTATUS(status), sig);
        }
        else if (WIFSIGNALED(status))
        {
            printf("Process %d terminated by signal %d (signo: %d)\n", pid, WTERMSIG(status), sig);
        }
    }
}

void
setup_signal_handler()
{
    struct sigaction sa;
    sa.sa_handler = handle_ctrl_c;
    sa.sa_flags = SA_RESTART;
    sigaction(SIGINT, &sa, NULL);

    sa.sa_handler = handle_sig_child;
    sa.sa_flags = SA_RESTART;
    sigaction(SIGCHLD, &sa, NULL);
}

void format_current_path(char* path, const size_t size)
{
    if (path == NULL)
        return;

    if (strlen(path) > size)
    {
        path[size - 1] = '\0';
        return;
    }

    char* home = getenv("HOME");
    if (home == NULL)
        return;

    if (strncmp(path, home, strlen(home)) == 0)
    {
        char* new_path = malloc(size);
        if (new_path == NULL)
            return;

        memset(new_path, 0, size);
        snprintf(new_path, size, "~%s", path + strlen(home));
        strncpy(path, new_path, size);
        free(new_path);
    }
}

int
main()
{
    setup_signal_handler();

    for (;;)
    {
        job = job_new();
        if (job == NULL)
            exit(EXIT_FAILURE);

        char path[4096];
        memset(path, 0, sizeof(path));

        format_current_path(getcwd(path, sizeof(path)), sizeof(path));

        char prompt[4096];
        memset(prompt, 0, sizeof(prompt));
        snprintf(prompt, sizeof(prompt), GREEN "yrsh" RESET "@" GREEN "%s" RESET "> ", path);

        line = readline(prompt);
        if (line == NULL)
            exit(EXIT_FAILURE);

        /* Create a new string with new line for lexer only.
           Meanwhile, readline does not need new line characters at the end of
           the string because it will mess up the history.
         */

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
        free(line);
        free(line_with_newl);
        job_free(job);

        job = NULL;
        line = NULL;
    }


    return 0;
}
