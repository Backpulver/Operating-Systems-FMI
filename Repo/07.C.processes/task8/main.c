#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		errx(1, "Usage: %s <file>", argv[0]);
	}

	pid_t pid = fork();
	if (pid == -1)
	{
		err(2, "Failed to fork");
	}

	struct stat st;

	if (pid == 0)
	{
		int fd;
		if (stat(argv[1], &st) == -1)
		{
			if ((fd = open(argv[1], O_CREAT | O_WRONLY, 0644)) == -1)
			{
				err(3, "Failed to open %s", argv[1]);
			}
		}
		else
		{
			if ((fd = open(argv[1], O_TRUNC | O_WRONLY)) == -1)
			{
				err(4, "Failed to open %s", argv[1]);
			}
		}

		ssize_t writeBytes = write(fd, "foobar", 6);
		if (writeBytes == -1)
		{
			err(5, "Failed to write to %s", argv[1]);
		}

		if (writeBytes != 6)
		{
			err(6, "Partial write to %s", argv[1]);
		}

		close(fd);
	}
	else
	{
		if (wait(NULL) == -1)
		{
			err(7, "Wait failed");
		}

		int fd;
		if ((fd = open(argv[1], O_RDWR)) == -1)
		{
			err(8, "Failed to open %s", argv[1]);
		}

		char byte;
		ssize_t readBytes;
		while ((readBytes = read(fd, &byte, sizeof(byte))) > 0)
		{
			char buffer[2] = {byte, ' '};
			ssize_t writeBytes = write(1, &buffer, sizeof(buffer));

			if (writeBytes == -1)
			{
				err(9, "Failed to write to stdout");
			}

			if (writeBytes != sizeof(buffer))
			{
				err(10, "Partial to stdout");
			}
		}

		if (readBytes == -1)
		{
			err(11, "Failed to read %s", argv[1]);
		}

		close(fd);
	}

	exit(0);
}
