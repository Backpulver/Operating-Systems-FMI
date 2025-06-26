#include <stdio.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <err.h>

int main(int argc, char *argv[])
{
	if (argc != 4)
	{
		errx(1, "Usage: %s <command1> <command2> <command3>", argv[0]);
	}

	for (int i = 1; i < argc; i++)
	{
		pid_t pid = fork();
		if (pid == -1)
		{
			err(2, "Failed to fork");
		}

		if (pid == 0)
		{
			if (execlp(argv[i], argv[i], (char *)NULL) == -1)
			{
				err(6, "Failed to execute %s", argv[i]);
			}
		}
		else
		{
			int status;
			if (wait(&status) == -1)
			{
				err(3, "Failed to wait");
			}

			if (WIFEXITED(status))
			{
				int exitCode = WEXITSTATUS(status);
				char buffer[1024];
				int len = snprintf(buffer, sizeof(buffer), "The process with PID: %d exited with code: %d\n", pid, exitCode);
				ssize_t writeBytes = write(1, buffer, len);

				if (writeBytes == -1)
				{
					err(4, "Failed to write to stdout");
				}

				if (writeBytes != len)
				{
					err(5, "Partial write to stdout");
				}
			}
			else
			{
				errx(6, "Child was killed");
			}
		}
	}

	exit(0);
}
