// копирайте съдържанието на файл1 във файл2
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>

int main()
{
    int fd1, fd2;
    char c;

    fd1 = open("file1.txt", O_RDONLY);
    if (fd1 == -1) 
	{
        err(1, "Error opening file for reading");  
    }

    fd2 = open("file2.txt", O_CREAT | O_WRONLY, S_IRUSR | S_IWUSR);
    if (fd2 == -1) 
	{
        close(fd1); 
        err(2, "Error opening file for writing");
    }

    while (read(fd1, &c, 1) == 1) 
	{
        if (write(fd2, &c, 1) != 1) 
		{
            close(fd1);
            close(fd2);
            err(3, "Error writing to file");
        }
    }

    if (close(fd1) == -1) 
	{
        err(4, "Error closing source file");
    }
    if (close(fd2) == -1) 
	{
        err(5, "Error closing destination file");
    }

    exit(0);
}
