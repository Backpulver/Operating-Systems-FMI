// Реализирайте команда wc, с един аргумент подаден като входен параметър
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdio.h>
#include <err.h>
#include <stdbool.h>
#include <string.h>

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		errx(1, "Invalid number of arguments.\nUsage: %s <file>", argv[0]);
	}

	int fd1;

	if ((fd1 = open(argv[1], O_RDONLY)) == -1)
	{
		err(2, "File failed to open in read mode");
	}

	char byte;
	bool isWord = false;
	int lines = 0;
	int words = 0;
	int chars = 0;
	int readSize;

	while ((readSize = read(fd1, &byte, 1)) > 0)
	{
		chars++;

		if (byte == '\n')
		{
			lines++;
		}

		if (byte == ' ' || byte == '\n' || byte == '\t')
		{
			if (isWord)
			{
				words++;
				isWord = false;
			}
		}
		else
		{
			isWord = true;
		}
	}

	if (readSize == -1)
	{
		err(3, "Failed to read from file");
	}

	if (isWord)
	{
		words++;
	}

	char buff[1024];
	snprintf(buff,
			 sizeof(buff),
			 "File %s has:\n%d number of lines.\n%d number of words.\n%d number of chars.\n",
			 argv[1], lines, words, chars);

	if (write(1, buff, strlen(buff)) != (ssize_t)strlen(buff))
	{
		err(5, "Failed to write to stdout");
	}

	close(fd1);
	exit(0);
}
