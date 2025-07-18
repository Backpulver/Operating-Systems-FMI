#include <errno.h>
#include <unistd.h>
#include <err.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char* argv[])
{
	if (argc != 3)
	{
		errx(1, "Invalid number of arguments, Usage: %s <broken_msg_file> <msg_file>", argv[0]);
	}

	int fd_in = open(argv[1], O_RDONLY);
	if (fd_in == -1)
	{
		close(fd_in);
		err(2, "Error opeing file %s", argv[1]);
	}
	int fd_out = open(argv[2], O_CREAT | O_WRONLY | O_TRUNC, S_IRUSR | S_IWUSR);
	if (fd_out == -1)
	{
		close(fd_out);
		err(3, "Error opening file %s", argv[2]);
	}

	char buffer;
	ssize_t read_bytes;

	while ( (read_bytes = read(fd_in, &buffer, 1)) == 1)
	{
		if (buffer == 0x55)
		{
			char length;
			if (read(fd_in, &length, 1) != 1)
			{
				close(fd_in);
				close(fd_out);
				err(3, "Failed to read message length");
			}

			char* msg = malloc(length);
			if (!msg)
			{
				close(fd_in);
				close(fd_out);
				err(4, "Memory allocation failed");
			}

			msg[0]=0x55;
			msg[1]=length;

			if (read(fd_in, msg + 2, length - 2) != length - 2)
			{
				free(msg);
				close(fd_in);
				close(fd_out);
				err(5, "Failed to read complete message");
			}

			char checksum = 0;
			for (int i = 0; i < length - 1; i++)
			{
				checksum = checksum ^ msg[i];
			}

			if (checksum == msg[length-1])
			{
				if(write(fd_out, msg, sizeof(msg)) == -1)
				{
					free(msg);
					close(fd_in);
					close(fd_out);
					err(6, "Error writing message to output file");
				}
			}

			free(msg);
		}
	}

	if (read_bytes == -1)
	{
		close(fd_in);
		close(fd_out);
		err(7, "Error reading from input file");
	}

	close(fd_in);
	close(fd_out);
	exit(0);
}
