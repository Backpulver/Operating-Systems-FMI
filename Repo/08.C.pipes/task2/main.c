#include <stdlib.h>
#include <err.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>
#include <stdio.h>

int main(const int argc, const char *const argv[])
{
	if (argc != 2)
	{
		errx(1, "Invalid number of arguments. Usage: %s <string>", argv[0]);
	}

	int pf[2];
	if (pipe(pf) == -1)
	{
		err(2, "Could not create pipe");
	}

	const pid_t child_pid = fork();

	if (child_pid == -1)
	{
		err(3, "Could not fork.");
	}

	if (child_pid == 0)
	{
		close(pf[1]);
		char buf;

		while (read(pf[0], &buf, 1) > 0)
		{
			if (write(1, &buf, 1) != 1)
			{
				err(4, "Could not write in child to stdout");
			}
		}

		close(pf[0]);
		exit(0);
	}

	close(pf[0]);

	ssize_t len = strlen(argv[1]);
	if (write(pf[1], argv[1], len) != len)
	{
		err(5, "Could not write in parent to child");
	}

	close(pf[1]);

	wait(NULL);

	exit(0);
}
