#include <stdio.h>
#include <err.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    if (3 != argc)
    {
        errx(1, "Usage: %s <file1> <file2>", argv[0]);
    }

    int fd1;
    if (-1 == (fd1 = open(argv[1], O_RDONLY)))
    {
        err(2, "Failed to open %s", argv[1]);
    }

    off_t fileSize;
    if (-1 == (fileSize = lseek(fd1, 0, SEEK_END)))
    {
        err(3, "Failed to seek to the end");
    }

    if (-1 == lseek(fd1, 0, SEEK_SET))
    {
        err(4, "Failed to rewind to the begining");
    }

    char *buffer = malloc(fileSize);
    if (!buffer)
    {
        err(5, "Failed to allocate memory");
    }

    ssize_t readBytes;
    if (-1 == (readBytes = read(fd1, buffer, fileSize)))
    {
        free(buffer);
        err(6, "Failed to read %s", argv[1]);
    }

    int fd2;
    if (-1 == (fd2 = open(argv[2], O_CREAT | O_TRUNC | O_WRONLY, 0644)))
    {
        free(buffer);
        err(7, "Failed to open %s", argv[2]);
    }

    ssize_t writeBytes = write(fd2, buffer, readBytes);
    if (writeBytes != readBytes)
    {
        free(buffer);
        err(8, "Failed or partial write to %s", argv[2]);
    }

    close(fd1);
    close(fd2);
    free(buffer);

    exit(0);
}