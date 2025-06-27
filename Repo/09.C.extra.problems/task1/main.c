#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <stdbool.h>

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        errx(1, "Invalid number of arguments. Usage: %s <command1> <command2>", argv[0]);
    }

    int pipe1[2];
    if (pipe(pipe1) == -1)
    {
        err(2, "Could not create pipe");
    }

    pid_t childPid1 = fork();
    if (childPid1 == -1)
    {
        err(3, "Could not fork");
    }

    if (childPid1 == 0)
    {
        close(pipe1[1]);
        close(0);

        if (dup2(pipe1[0], 0) == -1)
        {
            err(4, "Could not dup2");
        }

        if (execlp(argv[1], argv[1], (char *)NULL) == -1)
        {
            err(5, "Could not exec");
        }
    }

    int pipe2[2];
    if (pipe(pipe2) == -1)
    {
        err(6, "Could not create pipe");
    }

    pid_t childPid2 = fork();
    if (childPid2 == -1)
    {
        err(7, "Could not fork");
    }

    if (childPid2 == 0)
    {
        close(pipe2[1]);
        close(pipe1[0]);
        close(pipe1[1]);
        close(0);

        if (dup2(pipe2[0], 0) == -1)
        {
            err(8, "Could not dup2");
        }

        if (execlp(argv[2], argv[2], (char *)NULL) == -1)
        {
            err(9, "Could not exec");
        }
    }

    close(pipe1[0]);
    close(pipe2[0]);

    bool isEven = false;
    char byte;
    char line[1024];
    int i = 0;
    ssize_t readBytes;

    while ((readBytes = read(0, &byte, sizeof(byte))) > 0)
    {
        if (i >= 1023)
        {
            errx(10, "Line too long");
        }

        line[i++] = byte;

        if (byte == '\n')
        {
            if (isEven)
            {
                if (write(pipe1[1], line, i) != i)
                {
                    err(11, "Could not write in parent to %s", argv[1]);
                }
            }
            else
            {
                if (write(pipe2[1], line, i) != i)
                {
                    err(12, "Could not write in parent to %s", argv[2]);
                }
            }

            isEven = !isEven;
            i = 0;
        }
    }

    if (readBytes == -1)
    {
        err(13, "Read failed");
    }

    close(pipe1[1]);
    close(pipe2[1]);

    while (wait(NULL) > 0)
        ;

    exit(0);
}