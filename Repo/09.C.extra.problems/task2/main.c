#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdbool.h>

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        errx(1, "Usage: %s <command>", argv[0]);
    }

    char line[1024];
    ssize_t readBytes;
    int i = 0;
    char byte;

    while ((readBytes = read(0, &byte, sizeof(byte))) > 0)
    {
        if (i >= 1023)
        {
            errx(2, "Line too long");
        }

        line[i++] = byte;

        if (byte == '\n')
        {
            line[i - 1] = '\0';

            char *tokens[128];
            int tokenCount = 0;

            tokens[tokenCount++] = argv[1];

            char *token = strtok(line, " ");
            while (token != NULL && tokenCount < 127)
            {
                tokens[tokenCount++] = token;
                token = strtok(NULL, " ");
            }

            tokens[tokenCount] = NULL;

            pid_t pid = fork();
            if (pid == -1)
            {
                err(3, "Could not fork");
            }

            if (pid == 0)
            {
                if (execvp(argv[1], tokens) == -1)
                {
                    err(4, "Could not exec %s", argv[1]);
                }
            }

            if (waitpid(pid, NULL, 0) == -1)
            {
                err(5, "Failed to waitpid");
            }

            i = 0;
        }
    }

    if (readBytes == -1)
    {
        err(6, "Read failed");
    }

    exit(0);
}