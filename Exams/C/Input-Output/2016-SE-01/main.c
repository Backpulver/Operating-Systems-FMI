#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <err.h>
#include <stdint.h>

int cmpByte(const void *, const void *);
int cmpByte(const void *a, const void *b)
{
    const uint8_t byteA = *(const uint8_t *)a;
    const uint8_t byteB = *(const uint8_t *)b;

    if (byteA < byteB)
        return -1;
    if (byteA > byteB)
        return 1;
    return 0;
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        errx(1, "Invalid number of arguments. Usage: %s <file>", argv[0]);
    }

    int fd;
    if ((fd = open(argv[1], O_RDWR)) == -1)
    {
        err(2, "Failed to open file: %s", argv[1]);
    }

    struct stat st;
    if (fstat(fd, &st) == -1)
    {
        err(3, "Failed to fstat");
    }

    int fileSize = st.st_size;
    uint8_t *buffer = malloc(fileSize);

    if (!buffer)
    {
        err(4, "Failed to allocate memory");
    }

    ssize_t readBytes = read(fd, buffer, fileSize);
    if (readBytes != fileSize)
    {
        err(5, "Could not read from file: %s", argv[1]);
    }

    qsort(buffer, fileSize, sizeof(uint8_t), cmpByte);

    if (lseek(fd, 0, SEEK_SET) == -1)
    {
        err(6, "Failed to seek to begining");
    }

    if (write(fd, buffer, fileSize) != fileSize)
    {
        err(5, "Failed to write to file: %s", argv[1]);
    }

    close(fd);
    free(buffer);

    exit(0);
}
