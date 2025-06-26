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
    if (argc != 4)
    {
        errx(1, "Usage: %s <command1> <command2> <file>", argv[0]);
    }

    int fd;
    struct stat st;
    if (stat(argv[3], &st) == -1)
    {
        if ((fd = open(argv[3], O_CREAT | O_WRONLY, 0644)) == -1)
        {
            err(2, "Failed to open %s", argv[3]);
        }
    }
    else
    {
        if ((fd = open(argv[3], O_APPEND | O_WRONLY)) == -1)
        {
            err(2, "Failed to open %s", argv[3]);
        }
    }

    close(fd);

    for (int i = 1; i < argc - 1; i++)
    {
        pid_t pid = fork();

        if (pid == -1)
        {
            err(3, "Failed to fork");
        }

        if (pid == 0)
        {
            if (execlp(argv[i], argv[i], (char *)NULL) == -1)
            {
                err(4, "Failed to exec %s", argv[i]);
            }
        }
        else
        {
            int status;
            if (wait(&status) == -1)
            {
                err(5, "Failed to wait");
            }

            if (WIFEXITED(status))
            {
                int exitCode = WEXITSTATUS(status);
                if (exitCode == 0)
                {
                    if ((fd = open(argv[3], O_APPEND | O_WRONLY)) == -1)
                    {
                        err(6, "Failed to open %s", argv[3]);
                    }

                    ssize_t bytesWritten = write(fd, argv[i], strlen(argv[i]));
                    if (bytesWritten == -1)
                    {
                        err(7, "Failed to write to stdout");
                    }

                    if (bytesWritten != (ssize_t)strlen(argv[i]))
                    {
                        err(8, "Partial write to stdout");
                    }

                    close(fd);
                }
                else
                {
                    char buffer[1024];
                    int len = snprintf(buffer,
                                       sizeof(buffer),
                                       "The program %s exited with code: %d\n",
                                       argv[i], exitCode);
                    ssize_t written = write(1, buffer, len);

                    if (written == -1)
                    {
                        errx(9, "Failed to write to stdout");
                    }

                    if (written != len)
                    {
                        errx(10, "Partial write to stdout");
                    }
                }
            }
            else
            {
                errx(11, "Child was killed");
            }
        }
    }

    exit(0);
}