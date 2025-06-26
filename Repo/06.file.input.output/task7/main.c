#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

char *buildPath(const char *, const char *);
char *buildPath(const char *dir, const char *filename)
{
    size_t dirLen = strlen(dir);
    size_t fileLen = strlen(filename);
    size_t pathLen = dirLen + fileLen + 2;

    char *path = malloc(pathLen);
    if (!path)
    {
        err(1, "Failed to allocate memory");
    }

    strcpy(path, dir);

    if (dirLen > 0 && dir[dirLen - 1] != '/')
    {
        strcat(path, "/");
    }

    strcat(path, filename);

    return path;
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        errx(2, "Usage: %s <source/s> <direcotry>", argv[0]);
    }

    for (int i = 1; i < argc - 1; i++)
    {
        int fd1;
        if (-1 == (fd1 = open(argv[i], O_RDONLY)))
        {
            err(3, "Failed to open %s", argv[i]);
        }

        off_t fileSize;
        if (-1 == (fileSize = lseek(fd1, 0, SEEK_END)))
        {
            err(4, "Failed to seek to the end");
        }

        if (-1 == lseek(fd1, 0, SEEK_SET))
        {
            err(5, "Failed to rewind to the begining");
        }

        const char *filename = strrchr(argv[i], '/');
        filename = (filename != NULL) ? filename + 1 : argv[i];

        char *destination = buildPath(argv[argc - 1], filename);

        if (!destination)
        {
            err(6, "Failed to allocate memory");
        }

        int fd2;
        if (-1 == (fd2 = open(destination, O_CREAT | O_TRUNC | O_WRONLY, 0644)))
        {
            free(destination);
            err(7, "Failed to %s", argv[argc - 1]);
        }

        free(destination);

        char buffer[4096];
        ssize_t readBytes;
        while ((readBytes = read(fd1, buffer, sizeof(buffer))) > 0)
        {
            ssize_t writeBytes = write(fd2, buffer, readBytes);

            if (-1 == writeBytes)
            {
                err(8, "Failed to write to destination");
            }

            if (writeBytes != readBytes)
            {
                err(9, "Partial write to destination");
            }
        }

        if (-1 == readBytes)
        {
            err(10, "Failed to read %s", argv[i]);
        }

        close(fd1);
        close(fd2);
    }

    exit(0);
}