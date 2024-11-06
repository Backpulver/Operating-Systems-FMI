/*
	Реализирайте команда head без опции (т.е. винаги да извежда
	на стандартния изход само първите 10 реда от съдържанието на
	файл подаден като първи параматър)
*/

#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int main(int argc, char* argv[])
{
    int fd1;
    int i = 0;
    char c;

    if (argc != 2)
    {
	    errx(1, "Invalid number of arguments. Usage: %s file", argv[0]);
    }

    fd1 = open(argv[1], O_RDONLY);
    if (fd1 == -1)
    {
        err(2, "File failed to open in read mode");
    }

    while (read(fd1, &c, sizeof(c)) == sizeof(c))
    {
        if (c == '\n')
        {
            i++;
        }

        if (write(1, &c, 1) != 1)
        {
            perror("Failed to write character to stdout");
            close(fd1); 
            exit(3);
        }

        if (i == 10)
        {
            break;
        }
    }

    if (close(fd1) == -1)
    {
        perror("Failed to close file");
        exit(4);
    }

    exit(0);
}
