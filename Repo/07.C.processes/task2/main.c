/*
	Да се напише програма на C, която изпълнява команда ls с точно един аргумент.
*/

#include <unistd.h>
#include <stdlib.h>
#include <err.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		errx(1, "Usage: %s <argument for ls>", argv[0]);
	}

	if (execlp("ls", "ls", argv[1], (char *)NULL) == -1)
	{
		err(2, "Execl error");
	}

	exit(0);
}
