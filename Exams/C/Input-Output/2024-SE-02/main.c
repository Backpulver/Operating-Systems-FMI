#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <stdint.h>

#define MAGIC_NUMBER 0x21494D46 

typedef struct __attribute__((__packed__))
{
  uint32_t magic;
  uint32_t packetCount;
  uint64_t originalSize; 
} Header;

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        errx(1, "Invalid number of arguments.\n Usage: %s <compressed file>  <result file>", argv[0]);
    }

	

    exit(0);
}
