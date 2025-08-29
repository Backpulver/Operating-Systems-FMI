#include <err.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

typedef struct
{
	uint16_t offset;
	uint8_t ogByte;
	uint8_t newByte;
} Patch;

int fileSize(int);
int fileSize(int fd)
{
	struct stat st;
	if (fstat(fd, &st) == -1)
	{
		err(2, "Failed to fstat");
	}

	return st.st_size;
}

int main(int argc, char *argv[])
{
	if (argc != 4)
	{
		errx(1, "Invalid argument count.\nUsage: %s <patch.bin> <f1.bin> <f2.bin>", argv[0]);
	}

	int fd[3];

	if ((fd[0] = open(argv[1], O_RDONLY)) == -1)
	{
		err(3, "Failed to open %s", argv[1]);
	}

	int patchSize = fileSize(fd[0]);

	if (patchSize % 4 != 0)
	{
		err(4, "Invalid file content");
	}

	if ((fd[1] = open(argv[2], O_RDONLY)) == -1)
	{
		err(5, "Failed to open %s", argv[2]);
	}

	int f1Size = fileSize(fd[1]);

	if ((fd[2] = open(argv[3], O_CREAT | O_TRUNC | O_WRONLY, 0644)) == -1)
	{
		err(7, "Failed to open %s", argv[3]);
	}

	uint8_t byte;
	ssize_t readBytes;
	while ((readBytes = read(fd[1], &byte, sizeof(byte))) == sizeof(byte))
	{
		if (write(fd[2], &byte, sizeof(byte)) != sizeof(byte))
		{
			err(8, "Failed to write to %s", argv[3]);
		}
	}

	if (readBytes != 0)
	{
		err(9, "Failed to read from %s", argv[2]);
	}

	Patch data;

	while ((readBytes = read(fd[0], &data, sizeof(data))) == sizeof(data))
	{
		uint16_t offset = data.offset;

		if (offset >= f1Size)
		{
			errx(10, "Offset is larger than the size of %s", argv[2]);
		}

		if (pread(fd[1], &byte, sizeof(byte), offset) != sizeof(byte))
		{
			err(11, "Failed to read from %s", argv[2]);
		}

		if (byte != data.ogByte)
		{
			errx(12, "Wrong original byte");
		}

		if (pwrite(fd[2], &data.newByte, sizeof(data.newByte), offset) != sizeof(data.newByte))
		{
			err(13, "Failed to write to %s", argv[3]);
		}
	}

	if (readBytes != 0)
	{
		err(14, "Failed to read from %s", argv[1]);
	}

	close(fd[0]);
	close(fd[1]);
	close(fd[2]);
	exit(0);
}