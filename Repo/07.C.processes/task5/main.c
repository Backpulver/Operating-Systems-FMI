/*
	Да се напише програма на C, която е аналогична на горния пример, но
	принуждава бащата да изчака сина си да завърши.
*/

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <err.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(void)
{
	int n = 100;
	int processExitStatus;

	pid_t a = fork();
	if (a == -1)
	{
		err(1, "Failed to fork");
	}

	if (a > 0)
	{
		if (wait(&processExitStatus) == -1)
		{
			err(2, "Wait failed");
		}

		if (WIFEXITED(processExitStatus))
		{
			int exitCode = WEXITSTATUS(processExitStatus);
			if (exitCode != 0)
			{
				errx(3, "Child exited with status %d", exitCode);
			}
		}
		else
		{
			errx(4, "Child was killed");
		}

		for (int i = 0; i < n; i++)
		{
			if (write(1, "Father\n", sizeof("Father\n")) == -1)
			{
				err(5, "Failed to write");
			}
		}
	}
	else
	{
		for (int i = 0; i < n; i++)
		{
			if (write(1, "Son\n", sizeof("Son\n")) == -1)
			{
				err(6, "Failed to write");
			}
		}
	}

	exit(0);
}
