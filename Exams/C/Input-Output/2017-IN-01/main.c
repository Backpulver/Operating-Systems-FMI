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
	uint8_t length;
	uint8_t notUsed;
} idx;

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
	if (argc != 5)
	{
		errx(1, "Invalid number of arguments.\nUsage: %s <input.dat> <input.idx> <output.dat> <output.idx>", argv[0]);
	}

	int inputDat, inputIdx, outputDat, outputIdx;

	if ((inputDat = open(argv[1], O_RDONLY)) == -1)
	{
		err(2, "Failed to open %s", argv[1]);
	}

	int inputDatSize = fileSize(inputDat);

	if ((inputIdx = open(argv[2], O_RDONLY)) == -1)
	{
		err(4, "Failed to open %s", argv[2]);
	}

	int inputIdxSize = fileSize(inputIdx);

	if (inputIdxSize % 4 != 0)
	{
		errx(5, "Invalid file content for %s", argv[2]);
	}

	if ((outputDat = open(argv[3], O_CREAT | O_TRUNC | O_WRONLY, 0644)) == -1)
	{
		err(6, "Failed to open %s", argv[3]);
	}

	if ((outputIdx = open(argv[4], O_CREAT | O_TRUNC | O_WRONLY, 0644)) == -1)
	{
		err(7, "Failed to open %s", argv[4]);
	}

	ssize_t readBytes;
	idx buffer;

	while ((readBytes = read(inputIdx, &buffer, sizeof(buffer))) == sizeof(buffer))
	{
		if (buffer.offset > inputDatSize)
		{
			errx(8, "Invalid offset");
		}

		if (lseek(inputDat, buffer.offset, SEEK_SET) == -1)
		{
			err(9, "Failed to seek");
		}

		uint8_t string[256];
		ssize_t readRes = read(inputDat, string, buffer.length);

		if (readRes == -1)
		{
			err(10, "Failed to read from %s", argv[1]);
		}
		else if (readRes != buffer.length)
		{
			err(11, "Unexpected EOF from %s", argv[1]);
		}

		if (buffer.length == 0)
		{
			continue;
		}

		if (string[0] < 'A' || string[0] > 'Z')
		{
			continue;
		}

		idx buffer2;
		buffer2.notUsed = 0;
		buffer2.length = buffer.length;
		int offset2;

		if ((offset2 = lseek(outputDat, 0, SEEK_END)) == -1)
		{
			err(12, "Failed to seek");
		}

		buffer2.offset = offset2;

		if (write(outputDat, string, buffer.length) != buffer.length)
		{
			err(13, "Failed to write to %s", argv[3]);
		}

		if (write(outputIdx, &buffer2, sizeof(buffer2)) != sizeof(buffer2))
		{
			err(14, "Failed to write to %s", argv[4]);
		}
	}

	if (readBytes != 0)
	{
		err(15, "Failed to read from %s", argv[2]);
	}

	close(inputDat);
	close(inputIdx);
	close(outputDat);
	close(outputIdx);
	exit(0);
}