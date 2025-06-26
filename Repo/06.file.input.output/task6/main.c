#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    for (int i = 1; i < argc; i++)
    {
        int fd;
        if (-1 == (fd = open(argv[i], O_RDONLY)))
        {
            err(1, "Failed to open %s", argv[i]);
        }

        off_t fileSize;
        if (-1 == (fileSize = lseek(fd, 0, SEEK_END)))
        {
            err(2, "Failed to seek to the end");
        }

        if (-1 == lseek(fd, 0, SEEK_SET))
        {
            err(3, "Failed to rewind to the begining");
        }

        char buffer[4096];
        ssize_t readBytes;
        while ((readBytes = read(fd, buffer, sizeof(buffer))) > 0)
        {
            ssize_t writeBytes = write(1, buffer, readBytes);

            if (-1 == writeBytes)
            {
                err(4, "Failed to write to stdout");
            }

            if (writeBytes != readBytes)
            {
                err(5, "Partial write to stdout");
            }
        }

        if (-1 == readBytes)
        {
            err(6, "Failed to read %s", argv[i]);
        }

        close(fd);
    }

    exit(0);
}