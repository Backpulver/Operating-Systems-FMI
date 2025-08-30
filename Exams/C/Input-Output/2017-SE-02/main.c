#include <err.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	bool isNumberLines = false;
	int argi = 1;

	if (argc >= 2)
	{
		if (strcmp(argv[1], "-n") == 0)
		{
			isNumberLines = true;
			argi = 2;
		}
	}

	int numberLine = 1;

	if (argi >= argc)
	{
		int fd = 0;

		ssize_t readByte;
		unsigned char byte;
		bool writeNumber = true;

		while ((readByte = read(fd, &byte, sizeof(byte))) == sizeof(byte))
		{
			if (writeNumber)
			{
				if (isNumberLines)
				{
					char buffer[64];
					int length = snprintf(buffer, sizeof(buffer), "%d ", numberLine);

					if (write(1, buffer, length) != length)
					{
						err(1, "Failed to write to stdout");
					}

					writeNumber = false;
				}
			}

			if (byte == '\n')
			{
				numberLine++;
				writeNumber = true;
			}

			if (write(1, &byte, sizeof(byte)) != sizeof(byte))
			{
				err(1, "Failed to write to stdout");
			}
		}

		if (readByte != 0)
		{
			err(1, "Failed to read from stdin");
		}
	}
	else
	{
		for (int i = argi; i < argc; i++)
		{
			int fd;

			if (strcmp(argv[i], "-") == 0)
			{
				fd = 0;
			}
			else
			{
				if ((fd = open(argv[i], O_RDONLY)) == -1)
				{
					err(1, "Failed to open %s", argv[i]);
				}
			}

			ssize_t readByte;
			unsigned char byte;
			bool writeNumber = true;

			while ((readByte = read(fd, &byte, sizeof(byte))) == sizeof(byte))
			{
				if (writeNumber)
				{
					if (isNumberLines)
					{
						char buffer[64];
						int length = snprintf(buffer, sizeof(buffer), "%d ", numberLine);

						if (write(1, buffer, length) != length)
						{
							err(1, "Failed to write to stdout");
						}

						writeNumber = false;
					}
				}

				if (byte == '\n')
				{
					numberLine++;
					writeNumber = true;
				}

				if (write(1, &byte, sizeof(byte)) != sizeof(byte))
				{
					err(1, "Failed to write to stdout");
				}
			}

			if (readByte != 0)
			{
				err(1, "Failed to read");
			}

			if (fd != 0)
			{
				close(fd);
			}
		}
	}

	exit(0);
}