#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        errx(1, "Usage: %s <command1> <command2>", argv[0]);
    }

    pid_t pids[2];

    for (int i = 0; i < 2; i++)
    {
        pids[i] = fork();

        if (pids[i] == -1)
        {
            err(2, "Failed to fork");
        }

        if (pids[i] == 0)
        {
            if (execlp(argv[i + 1], argv[i + 1], (char *)NULL) == -1)
            {
                err(3, "Failed to exec %s", argv[i + 1]);
            }
        }
    }

    int successFound = 0;
    for (int i = 0; i < 2; i++)
    {
        int status;
        pid_t pidFinish = wait(&status);
        if (pidFinish == -1)
        {
            err(4, "Wait failed");
        }

        if (WIFEXITED(status) && WEXITSTATUS(status) == 0)
        {
            char buffer[64];
            int len = snprintf(buffer, sizeof(buffer), "%d\n", pidFinish);
            ssize_t writeBytes = write(1, buffer, len);

            if (writeBytes == -1)
            {
                err(6, "Failed to write PID");
            }

            if (writeBytes != len)
            {
                err(7, "Partial write of PID");
            }

            successFound = 1;
            break;
        }
    }

    if (!successFound)
    {
        ssize_t writeBytes = write(1, "-1\n", strlen("-1\n"));
        if (writeBytes == -1)
        {
            err(5, "Write to stdout failed");
        }
    }

    while (wait(NULL) > 0)
        ;

    exit(0);
}