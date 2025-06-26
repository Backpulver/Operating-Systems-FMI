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
    if (argc == 1)
    {
        errx(1, "Usage: %s <command1> <command2>...<commandN>", argv[0]);
    }

    int numSuccess = 0;
    int numFail = 0;
    for (int i = 1; i < argc; i++)
    {
        pid_t pid = fork();
        if (pid == -1)
        {
            err(2, "Failed to fork");
        }

        if (pid == 0)
        {
            if (execlp(argv[i], argv[i], (char *)NULL) == -1)
            {
                err(3, "Failed to exec %s", argv[i]);
            }
        }
        else
        {
            int status;
            if (wait(&status) == -1)
            {
                err(4, "Failed to wait");
            }

            if (WIFEXITED(status))
            {
                int exitCode = WEXITSTATUS(status);
                if (exitCode == 0)
                {
                    numSuccess++;
                }
                else
                {
                    numFail++;
                }
            }
            else
            {
                errx(5, "Child was killed");
            }
        }
    }

    char buffer[1024];
    int len = snprintf(buffer, sizeof(buffer), "Succsessful commands: %d\nFailed commands: %d\n", numSuccess, numFail);
    ssize_t bytesWritten = write(1, buffer, len);
    if (bytesWritten == -1)
    {
        err(6, "Failed to write to stdout");
    }

    if (bytesWritten != len)
    {
        err(7, "Partial write to stdout");
    }

    exit(0);
}