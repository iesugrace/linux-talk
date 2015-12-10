/*
 * Author: Joshua Chen
 * Date: Jun 2014
 * Location: Shenzhen
 * Description: demonstrate the invocation of login shell
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
   char *cmd = "/bin/bash";
   char *newargv[] = { "xxyy", NULL };
   char *newenv[] = { NULL };

   if (argc > 1 && argv[1][0] == '-')
   {
       newargv[0] = "-xxyy";
   }

   execve(cmd, newargv, newenv);
   perror("execve");
   exit(EXIT_FAILURE);
}

