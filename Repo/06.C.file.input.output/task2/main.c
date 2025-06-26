/*
    Реализирайте команда head без опции (т.е. винаги да извежда
    на стандартния изход само първите 10 реда от съдържанието на
    файл подаден като първи параматър)
*/
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <err.h>

int main(int argc, char *argv[])
{
    char byte;
    int fd1;
    int i = 0;

    if (argc != 2)
    {
        errx(1, "Invalid number of arguments.\nUsage: %s <file>", argv[0]);
    }

    if ((fd1 = open(argv[1], O_RDONLY)) == -1)
    {
        err(2, "File failed to open in read mode");
    }

    int res;
    while (1)
    {
        if ((res = read(fd1, &byte, sizeof(byte))) == -1)
        {
            err(3, "Failed to read from file: %s", argv[1]);
        }

        if (res == 0) break;

        if (res != sizeof(byte)) // for concept, not reachable
        {
            err(4, "Partial read, expected 1 byte but got %d", res);
        }

        if (byte == '\n')
        {
            i++;
        }

        if (write(1, &byte, 1) != res)
        {
            err(5, "Failed to write to stdout");
        }

        if (i == 10) break;
    }

    close(fd1);
    exit(0);
}
