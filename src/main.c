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
            exit(EXIT_FAILURE);
        }
    }

    return;
}

void
setup_signal_handler()
{
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));

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

    job_prompt(&job);

    return 0;
}
