#ifndef __YRSH_H__
#define __YRSH_H__ 1

/* Exposes definitions corresponding to the POSIX.1-2008 */
#define _POSIX_C_SOURCE 200809L

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <readline/readline.h>
#include <readline/history.h>


void dumb_shell();

#endif // __YRSH_H__
