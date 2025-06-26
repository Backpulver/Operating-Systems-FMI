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
	if (argc != 2)
	{
		errx(1, "Usage: %s <file>", argv[0]);
	}

	int fd;
	if ((fd = open(argv[1], O_CREAT | O_TRUNC | O_WRONLY, 0644)) == -1)
	{
		err(2, "Failed to open %s", argv[1]);
	}

	pid_t pid = fork();
	if (pid == -1)
	{
		err(3, "Failed to fork");
	}

	if (pid == 0)
	{
		ssize_t writeBytes = write(fd, "foo", strlen("foo"));
		if (writeBytes == -1)
		{
			err(4, "Failed to write to %s", argv[1]);
		}

		if (writeBytes != strlen("foo"))
		{
			err(5, "Partial write to %s", argv[1]);
		}

		close(fd);
	}
	else
	{
		if (wait(NULL) == -1)
		{
			err(6, "Wait failed");
		}

		close(fd);

		int pid2 = fork();

		if (pid2 == -1)
		{
			err(7, "Failed to fork");
		}

		if (pid2 == 0)
		{
			int fd2;
			if ((fd2 = open(argv[1], O_WRONLY | O_APPEND)) == -1)
			{
				err(8, "Failed to reopen %s", argv[1]);
			}

			ssize_t writeBytes = write(fd2, "bar", strlen("bar"));
			if (writeBytes == -1)
			{
				err(8, "Failed to write to %s", argv[1]);
			}

			if (writeBytes != strlen("bar"))
			{
				err(9, "Partial write to %s", argv[1]);
			}

			close(fd2);
		}
		else
		{
			if (wait(NULL) == -1)
			{
				err(6, "Wait failed");
			}
		}
	}

	exit(0);
}
