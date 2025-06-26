/*
	Да се напише програма на C, която създава процес дете и демонстрира
принцина на конкурентност при процесите.
*/

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <err.h>

int main(void)
{
	int n = 20;

	pid_t a = fork();
	if (a == -1)
	{
		err(1, "Failed to fork");
	}

	if (a > 0) // parent
	{
		for (int i = 0; i < n; i++)
		{
			if (write(1, "Father\n", sizeof("Father\n")) == -1)
			{
				err(2, "Failed to write");
			}
		}
	}
	else // child
	{
		for (int i = 0; i < n; i++)
		{
			if (write(1, "Son\n", sizeof("Son\n")) == -1)
			{
				err(3, "Failed to write");
			}
		}
	}

	exit(0);
}
