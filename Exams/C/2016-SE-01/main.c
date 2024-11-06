#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <err.h>

long get_file_size(char *filename) {
    FILE *fp = open(filename, "r");

    if (fp==NULL)
        return -1;

    if (lseek(fp, 0, SEEK_END) < 0) {
        close(fp);
        return -1;
    }

    long size = ftell(fp);
    close(fp);
    return size;
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        errx(1, "The porgram sorts only one file");
    }

    const char *filename = argv[1];
    int fd = open(filename, O_RDWR);
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

    unsigned char *buffer = malloc(fileSize);
    if (!buffer)
    {
        close(fd);
        err(4, "Cannot allocate memory");
    }

    if (read(fd, buffer, fileSize) != fileSize)
    {
        free(buffer);
        close(fd);
        err(5, "Cannot read");
    }

    qsort(buffer, fileSize, sizeof(unsigned char));

    if (lseek(fd, 0, SEEK_SET) < 0)
    {
        perror("lseek");
        free(buffer);
        close(fd);
        return 1;
    }

    if (write(fd, buffer, filesize) != filesize)
    {
        perror("write");
        free(buffer);
        close(fd);
        return 1;
    }

    free(buffer);
    close(fd);

    return 0;
}
