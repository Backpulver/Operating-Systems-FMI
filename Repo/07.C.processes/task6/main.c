#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		errx(1, "Usage: %s <command>", argv[0]);
	}

	pid_t pid = fork();
	int status;

	if (pid == -1)
	{
		err(2, "Failed to fork");
	}

	if (pid == 0)
	{
		if (execlp(argv[1], argv[1], (char *)NULL) == -1)
		{
			err(3, "Failed to execute %s", argv[1]);
		}
	}
	else
	{
		if (wait(&status) == -1)
		{
			err(4, "Wait failure");
		}

		if (WIFEXITED(status))
		{
			int exitCode = WEXITSTATUS(status);
			if (exitCode == 0)
			{
				ssize_t writeBytes = write(1, argv[1], strlen(argv[1]));
				if (writeBytes == -1)
				{
					err(5, "Failed to write to stdout");
				}

				if (writeBytes != (ssize_t)(argv[1]))
				{
					err(6, "Partial write to stdout");
				}
			}
			else
			{
				errx(7, "Child exited with code: %d", exitCode);
			}
		}
		else
		{
			errx(8, "Child was killed");
		}
	}

	exit(0);
}
