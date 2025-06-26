// копирайте съдържанието на файл1 във файл2
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <err.h>

int main(void)
{
    char byte;
    int fd1;
    int fd2;

    fd1 = open("foo.txt", O_RDONLY);
    if (fd1 == -1)
    {
        err(1, "File failed to open in read mode");
    }

    if ((fd2 = open("bar.txt", O_CREAT | O_WRONLY, S_IRUSR | S_IWUSR)) == -1)
    {
        err(2, "File failed to open in write mode");
    }

    int res;
    while (1)
    {
        res = read(fd1, &byte, sizeof(byte));

        if (res == -1)
        {
            err(3, "Failed to read from foo.txt");
        }

        if (res == 0) break;

        if (res != sizeof(byte)) // for concept, not reachable
        {
            err(4, "Partial read, expected 1 byte but got %d", res);
        }

        if (write(fd2, &byte, sizeof(byte)) != res)
        {
            err(5, "Failed to write to bar.txt");
        }
    }

    close(fd1);
    close(fd2);
    exit(0);
}