#include <err.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

#define MAGIC_NUMBER 0x21494D46

typedef struct __attribute__((__packed__))
{
	uint32_t magic;
	uint32_t packetCount;
	uint64_t originalSize;
} Header;

int main(int argc, char *argv[])
{
	if (argc != 3)
	{
		errx(1, "Invalid number of arguments.\n Usage: %s <compressed file> <output file>", argv[0]);
	}

	int inputFd, outputFd;

	if ((inputFd = open(argv[1], O_RDONLY)) == -1)
	{
		err(2, "Failed to open %s", argv[1]);
	}

	if ((outputFd = open(argv[2], O_CREAT | O_TRUNC | O_WRONLY, 0644)) == -1)
	{
		err(3, "Failed to open %s", argv[2]);
	}

	Header header;

	if (read(inputFd, &header, sizeof(header)) != sizeof(header))
	{
		err(4, "Failed to read header from %s", argv[1]);
	}

	if (header.magic != 0x21494D46)
	{
		errx(5, "Wrong magic number for file");
	}

	uint8_t byte;
	uint64_t size = 0;

	for (uint32_t i = 0; i < header.packetCount; i++)
	{
		if (read(inputFd, &byte, sizeof(byte)) != sizeof(byte))
		{
			err(6, "Failed to read packet from %s", argv[1]);
		}

		int bit = (byte >> 7) & 1;
		int N = (byte & ((1 << 7) - 1));
		N++;

		if (bit == 0)
		{
			for (int j = 0; j < N; j++)
			{
				if (size >= header.originalSize)
				{
					errx(7, "Overflow: packet tries to write past original size %lu", header.originalSize);
				}

				if (read(inputFd, &byte, sizeof(byte)) != sizeof(byte))
				{
					err(8, "Failed to read byte from %s", argv[1]);
				}

				if (write(outputFd, &byte, sizeof(byte)) != sizeof(byte))
				{
					err(9, "Failed to write byte to %s", argv[2]);
				}

				size++;
			}
		}
		else if (bit == 1)
		{
			if (read(inputFd, &byte, sizeof(byte)) != sizeof(byte))
			{
				err(10, "Failed to read byte from %s", argv[1]);
			}

			for (int j = 0; j < N; j++)
			{
				if (size >= header.originalSize)
				{
					errx(11, "Overflow: packet tries to write past original size %lu", header.originalSize);
				}

				if (write(outputFd, &byte, sizeof(byte)) != sizeof(byte))
				{
					err(12, "Failed to write byte to %s", argv[2]);
				}

				size++;
			}
		}
	}

	if (size != header.originalSize)
	{
		errx(13, "Original size of file missmatch: expected %ld, got %ld", header.originalSize, size);
	}

	close(inputFd);
	close(outputFd);
	exit(0);
}
