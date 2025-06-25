#include <stdio.h>
#include <err.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        errx(1, "Usage: %s <file1> <file2>", argv[0]);
    }

    char tmpname[] = "tmpfile_XXXXXX";
    int fd3;
    if ((fd3 = mkstemp(tmpname)) == -1)
    {
        err(2, "Failed to create temporary file");
    }
    close(fd3);

    if (rename(argv[1], tmpname) == -1)
    {
        err(3, "Failed to rename %s to %s", argv[1], tmpname);
    }

    if (rename(argv[2], argv[1]) == -1)
    {
        rename(tmpname, argv[1]);
        err(4, "Failed to rename %s to %s", argv[2], argv[1]);
    }

    if (rename(tmpname, argv[2]) == -1)
    {
        err(5, "Failed to rename %s to %s", tmpname, argv[2]);
    }

    exit(0);
}