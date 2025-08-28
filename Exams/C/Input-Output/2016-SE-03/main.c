#include <err.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <unistd.h>

int cmpUint32(const void *, const void *);
int cmpUint32(const void *a, const void *b)
{
	const uint32_t numA = *(const uint32_t *)a;
	const uint32_t numB = *(const uint32_t *)b;
	if (numA > numB)
		return 1;
	if (numA < numB)
		return -1;
	return 0;
}

int main(int argc, char *argv[])
{
	if (argc != 2)
	{
		errx(1, "Usage: %s <binary file with uint32_t numbers>", argv[0]);
	}

	int fd;
	if ((fd = open(argv[1], O_RDWR)) == -1)
	{
		err(2, "Failed to open file %s", argv[1]);
	}

	struct stat st;
	if (fstat(fd, &st) == -1)
	{
		err(3, "Failed to fstat");
	}

	int fileSize = st.st_size;
	if (fileSize % sizeof(uint32_t) != 0)
	{
		errx(4, "Invalid file content");
	}

	uint32_t *buffer = malloc(fileSize);
	if (!buffer)
	{
		err(5, "Failed to allocate memory");
	}

	ssize_t readBytes = read(fd, buffer, fileSize);
	if (readBytes != fileSize)
	{
		err(6, "Failed to read from %s", argv[1]);
	}

	qsort(buffer, fileSize / sizeof(uint32_t), sizeof(uint32_t), cmpUint32);

	if (lseek(fd, 0, SEEK_SET) == -1)
	{
		err(7, "Failed to seek to begining");
	}

	if (write(fd, buffer, fileSize) != fileSize)
	{
		err(8, "Failed to write to file %s", argv[1]);
	}

	close(fd);
	free(buffer);
	exit(0);
}