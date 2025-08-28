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
} FileStruct;

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
	if (argc != 4)
	{
		errx(1, "Invalid argument count.\nUsage: %s <f1.bin> <f2.bin> <patch.bin>", argv[0]);
	}

	int fd[3];

	if ((fd[0] = open(argv[1], O_RDONLY)) == -1)
	{
		err(2, "Failed to open %s", argv[1]);
	}

	int f1Size = fileSize(fd[0]);

	if ((fd[1] = open(argv[2], O_RDONLY)) == -1)
	{
		err(4, "Failed to open %s", argv[2]);
	}

	int f2Size = fileSize(fd[1]);

	if ((fd[2] = open(argv[3], O_CREAT | O_TRUNC | O_WRONLY, 0644)) == -1)
	{
		err(5, "Failed to open %s", argv[3]);
	}

	if (f1Size != f2Size)
	{
		errx(6, "%s and %s are different sizes", argv[1], argv[2]);
	}

	if (f1Size > UINT16_MAX + 1)
	{
		errx(7, "File too large for uint16_t offset");
	}

	ssize_t readBytes;
	uint8_t byte1, byte2;

	while ((readBytes = read(fd[0], &byte1, sizeof(byte1))) == sizeof(byte1))
	{
		if ((read(fd[1], &byte2, sizeof(byte2)) != sizeof(byte2)))
		{
			err(7, "Failed reading fron %s", argv[1]);
		}

		if (byte1 == byte2)
		{
			continue;
		}

		FileStruct data;
		off_t pos;

		if ((pos = lseek(fd[0], 0, SEEK_CUR)) == -1)
		{
			err(8, "Failed to seek");
		}

		data.offset = (uint16_t)(pos - 1);
		data.ogByte = byte1;
		data.newByte = byte2;

		if (write(fd[2], &data, sizeof(data)) != sizeof(data))
		{
			err(9, "Failed to write to %s", argv[3]);
		}
	}

	if (readBytes != 0)
	{
		err(10, "Failed to read from %s", argv[0]);
	}

	close(fd[0]);
	close(fd[1]);
	close(fd[2]);
	exit(0);
}