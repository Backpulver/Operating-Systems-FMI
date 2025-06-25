/*
	Реализирайте команда swap, разменяща съдържанието на два файла, подадени като
	входни параметри. Приемаме, че двата файла имат еднакъв брой символи. Може да
	модифицирате решението, да работи и когато нямат еднакъв брой символи.
*/
#include <stdio.h>
#include <err.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>

void copyFile(int, int);
void copyFile(int fromFd, int toFd)
{
	off_t pos;
	if ((pos = lseek(fromFd, 0, SEEK_END)) == -1)
	{
		err(1, "Failed to lseek to end");
	}

	if (lseek(fromFd, 0, SEEK_SET) == -1)
	{
		err(2, "Failed to rewind to start of file");
	}

	char buf[4096];
	ssize_t readSize;

	while ((readSize = read(fromFd, buf, sizeof(buf))) > 0)
	{
		ssize_t bytesWritten = write(toFd, buf, readSize);
		if (bytesWritten != readSize)
		{
			err(3, "Partial or failed write");
		}
	}

	if (readSize == -1)
	{
		err(4, "Failed to read from file");
	}
}

int main(int argc, char *argv[])
{
	if (argc != 3)
	{
		errx(5, "Invalid number of arguments.\nUsage: %s <file1> <file2>", argv[0]);
	}

	int fd1;
	if ((fd1 = open(argv[1], O_CREAT | O_RDONLY, 0644)) == -1)
	{
		err(6, "Failed to open %s for reading", argv[1]);
	}

	int fd2;
	if ((fd2 = open(argv[2], O_CREAT | O_RDONLY, 0644)) == -1)
	{
		err(7, "Failed to open %s for reading", argv[2]);
	}

	char tmpname[] = "tmpfile_XXXXXX";
	int fd3;
	if ((fd3 = mkstemp(tmpname)) == -1)
	{
		errx(8, "Failed to create a temp file");
	}

	copyFile(fd1, fd3);
	close(fd1);

	if ((fd1 = open(argv[1], O_TRUNC | O_WRONLY)) == -1)
	{
		err(9, "Failed to open %s for writing", argv[1]);
	}

	copyFile(fd2, fd1);
	close(fd2);

	if ((fd2 = open(argv[2], O_TRUNC | O_WRONLY)) == -1)
	{
		err(10, "Failed to open %s for writing", argv[2]);
	}

	copyFile(fd3, fd2);

	close(fd1);
	close(fd2);
	close(fd3);
	unlink(tmpname);

	exit(0);
}