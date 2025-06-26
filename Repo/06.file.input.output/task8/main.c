#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main(void)
{
    int fd1;
    if (-1 == (fd1 = open("/etc/passwd", O_RDONLY)))
    {
        err(1, "Failed to open /etc/passwd");
    }

    const char *home = getenv("HOME");
    if (home == NULL)
    {
        errx(2, "HOME environment variable not set");
    }

    char path[512];
    snprintf(path, sizeof(path), "%s/passwd", home);

    int fd2;
    if (-1 == (fd2 = open(path, O_CREAT | O_TRUNC | O_WRONLY, 0644)))
    {
        err(3, "Failed to open %s", path);
    }

    char byte;
    ssize_t readByte;

    while ((readByte = read(fd1, &byte, sizeof(byte))) > 0)
    {
        if (byte == ':')
        {
            byte = '?';
        }

        ssize_t writeByte;
        if (-1 == (writeByte = write(fd2, &byte, readByte)))
        {
            err(4, "Failed to write  to %s", path);
        }
    }

    if (-1 == readByte)
    {
        err(5, "Failed to read from /etc/passwd");
    }

    close(fd1);
    close(fd2);

    exit(0);
}