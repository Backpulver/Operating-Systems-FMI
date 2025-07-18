#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

int main(int argc, char *argv[])
{
    if (argc != 4)
    {
        errx(1, "Invalid number of arguments.\n Usage: %s <path to program> <number> <result file>", argv[0]);
    }

    char *programPath = argv[1];
	int number = atoi(argv[2]);
	char *resultFile = argv[3];
	
    for (int i = 0; i < number; i++)
    {
        pid_t pid = fork();
		if (pid == -1)
		{
			err(1, "Could not fork");
		}

		if (pid == 0)
		{
			unsigned char sBytes[2];
			int fd;
			if ((fd = open("/dev/null", O_RDONLY)) == -1)
			{
				err(1, "Failed to open /dev/null");
			}

			if (execlp() == -1)
			{
				err(1, "Exec failed");
			}
		}

    }
    

    exit(0);
}
