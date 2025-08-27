#include <err.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

int fileSize(int);
int fileSize(int fd)
{
	struct stat st;
	if (fstat(fd, &st) == -1)
	{
		err(3, "Failed to fstat");
	}

	return st.st_size;
}

int main(int argc, char *argv[])
{
	if (argc != 3)
	{
		errx(1, "Usage: %s <binary file with pairs> <binary file with numbers>", argv[0]);
	}

	int fd1, fd2, fd3;

	if ((fd1 = open(argv[1], O_RDONLY)) == -1)
	{
		err(2, "Failed to open file %s", argv[1]);
	}

	int size1 = fileSize(fd1);
	if (size1 % 8 != 0)
	{
		errx(4, "File %s must be divisible by 8", argv[1]);
	}

	if ((fd2 = open(argv[2], O_RDONLY)) == -1)
	{
		err(5, "Failed to open file %s", argv[2]);
	}

	int size2 = fileSize(fd2);
	if (size2 % 4 != 0)
	{
		errx(6, "File %s must be divisible by 4", argv[2]);
	}

	if ((fd3 = open("f3.bin", O_WRONLY | O_CREAT | O_TRUNC, 0644)) == -1)
	{
		err(7, "Failed to open file f3.bin");
	}

	uint32_t pair[2];
	uint32_t number;
	ssize_t readBytes;

	while ((readBytes = read(fd1, &pair, sizeof(pair))) == sizeof(pair))
	{
		if (pair[0] * sizeof(uint32_t) > (uint32_t)size2)
		{
			errx(8, "Invalid content");
		}

		if (lseek(fd2, pair[0] * sizeof(uint32_t), SEEK_SET) == -1)
		{
			err(9, "Failed to lseek");
		}

		for (uint32_t i = 0; i < pair[1]; i++)
		{
			ssize_t readBytesFd2 = read(fd2, &number, sizeof(number));
			if (readBytesFd2 == 0)
			{
				errx(10, "Unexpected EOF");
			}
			else if (readBytesFd2 == -1)
			{
				err(11, "Could not read from file: %s", argv[2]);
			}

			if (write(fd3, &number, sizeof(number)) != sizeof(number))
			{
				err(12, "Failed to write to file: f3.bin");
			}
		}
	}

	if (readBytes != 0)
	{
		err(13, "Failed to read %s", argv[1]);
	}

	close(fd1);
	close(fd2);
	close(fd3);
	exit(0);
}