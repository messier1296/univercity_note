#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

static size_t map_length(size_t file_size) {
  long page_size = sysconf(_SC_PAGE_SIZE);

  if (page_size <= 0) {
    perror("sysconf");
    exit(1);
  }
  return ((file_size + (size_t)page_size - 1) / (size_t)page_size) *
         (size_t)page_size;
}

int main(int argc, char *argv[]) {
  int fd, err;
  struct stat fs;
  char *p, *p0, *end;
  size_t maplen;
  int line_count, cnt;

  if (argc != 3) {
    exit(1);
  }
  line_count = atoi(argv[2]);

  fd = open(argv[1], O_RDONLY);
  if (fd < 0) {
    perror(argv[1]);
    exit(-1);
  }

  if (fstat(fd, &fs) < 0) {
    perror("fstat");
    exit(-1);
  }

  if (fs.st_size == 0) {
    close(fd);
    return 0;
  }

  maplen = map_length((size_t)fs.st_size);

  p = p0 = (char *)mmap(NULL, maplen, PROT_READ, MAP_PRIVATE, fd, 0);
  if (p == MAP_FAILED) {
    perror("mmap");
    exit(-1);
  }

  end = p0 + fs.st_size;
  cnt = 0;

  while (p < end && cnt < line_count) {
    if (*p++ == '\n') {
      cnt++;
    }
  }

  if (write(STDOUT_FILENO, p0, (size_t)(p - p0)) < 0) {
    perror("write");
    exit(-1);
  }

  err = munmap(p0, maplen);
  if (err) {
    perror("munmap");
    exit(-1);
  }
  close(fd);

  return 0;
}
