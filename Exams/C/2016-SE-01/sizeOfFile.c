#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <err.h>

int main(int argc, char const *argv[])
{
    if (argc != 2)
    {
        errx(1, "The porgram sorts only one file");
    }

    const char *filename = argv[1];
    int fd = open(filename, O_RDONLY);
    if (fd < 0)
    {
        err(2, "Cannot open file");
    }

    unsigned long fileSize = lseek(fd, 0, SEEK_END);
    if (fileSize < 0)
    {
        close(fd);
        err(3, "Oh no, it's broken...");
    }

    printf("%i", fileSize);
    close(fd);
    return 0;
}
