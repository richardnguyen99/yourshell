#ifndef __YRSH_H__
#define __YRSH_H__ 1

/* Exposes definitions corresponding to the POSIX.1-2008 */
#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

/* Add readline headers here otherwise compiling will fail */
#include <readline/history.h>
#include <readline/readline.h>

void
dumb_shell();

#define RED       "\033[0;31m"
#define GREEN     "\033[0;32m"
#define YELLOW    "\033[0;33m"
#define BLUE      "\033[0;34m"
#define MAGENTA   "\033[0;35m"
#define CYAN      "\033[0;36m"
#define WHITE     "\033[0;37m"
#define BOLD      "\033[1m"
#define UNDERLINE "\033[4m"
#define RESET     "\033[0m"

#endif // __YRSH_H__
