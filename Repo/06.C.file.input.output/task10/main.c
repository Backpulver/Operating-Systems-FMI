#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <err.h>
#include <sys/types.h>
#include <sys/stat.h>

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        errx(1, "Usage: %s <--min|--max|--print> <file>", argv[0]);
    }

    int fd = open(argv[2], O_RDONLY);
    if (fd == -1)
    {
        err(2, "Cannot open file %s", argv[2]);
    }

    uint8_t byte;
    ssize_t readBytes;
    int hasValue = 0;
    uint8_t result = 0;

    while ((readBytes = read(fd, &byte, sizeof(byte))) == sizeof(byte))
    {
        if (!hasValue)
        {
            result = byte;
            hasValue = 1;
        }

        if (strcmp(argv[1], "--min") == 0)
        {
            if (byte < result)
            {
                result = byte;
            }
        }
        else if (strcmp(argv[1], "--max") == 0)
        {
            if (byte > result)
            {
                result = byte;
            }
        }
        else if (strcmp(argv[1], "--print") == 0)
        {
            if (write(1, &byte, 1) == -1)
            {
                err(4, "Write failed");
            }
        }
        else
        {
            errx(3, "Unknown option %s", argv[1]);
        }
    }

    if (readBytes == -1)
    {
        err(5, "Read error");
    }

    close(fd);

    if (!hasValue)
    {
        errx(6, "Empty or invalid file");
    }

    if (strcmp(argv[1], "--min") == 0 || strcmp(argv[1], "--max") == 0)
    {
        char hexValue[5];
        int len = snprintf(hexValue, sizeof(hexValue), "%02x\n", result);

        if (write(1, &hexValue, len) == -1)
        {
            err(7, "Write failed");
        }
    }

    exit(0);
}
