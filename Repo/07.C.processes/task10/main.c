#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        errx(1, "Usage: %s <command1> <command2>", argv[0]);
    }

    pid_t pid1 = fork();
    if (pid1 == -1)
    {
        err(2, "Failed to fork");
    }

    if (pid1 == 0)
    {
        if (execlp(argv[1], argv[1], (char *)NULL) == -1)
        {
            err(3, "Failed to exec %s", argv[1]);
        }
    }
    else
    {
        int status1;
        if (wait(&status1) == -1)
        {
            err(4, "Failed to wait");
        }

        if (WIFEXITED(status1))
        {
            int exitCode1 = WEXITSTATUS(status1);
            if (exitCode1 == 0)
            {
                pid_t pid2 = fork();

                if (pid2 == -1)
                {
                    err(5, "Failed to fork");
                }

                if (pid2 == 0)
                {
                    if (execlp(argv[2], argv[2], (char *)NULL) == -1)
                    {
                        err(6, "Failed to exec %s", argv[2]);
                    }
                }
                else
                {
                    int status2;
                    if (wait(&status2) == -1)
                    {
                        err(7, "Failed to wait");
                    }

                    if (WIFEXITED(status2))
                    {
                        int exitCode2 = WEXITSTATUS(status2);
                        if (exitCode2 != 0)
                        {
                            errx(8, "Program %s exited with code %d", argv[2], exitCode2);
                        }
                    }
                    else
                    {
                        errx(9, "Child was killed");
                    }
                }

                exit(0);
            }
            else
            {
                exit(42);
            }
        }
        else
        {
            errx(10, "Child was killed");
        }
    }

    exit(0);
}