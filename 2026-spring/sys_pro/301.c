#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

#ifndef N
#define N BUFSIZ
#endif

int main(void) {
  char buf[N];
  int fps, fpd;
  int count;

  fps = open("src", O_RDONLY);
  if (fps < 0) {
    perror("open: src");
    exit(1);
  }

  fpd = open("dst", O_WRONLY | O_CREAT | O_TRUNC, 0644);
  if (fpd < 0) {
    perror("open: dst");
    close(fps);
    exit(1);
  }

  while ((count = read(fps, buf, N)) > 0) {
    if (write(fpd, buf, count) < 0) {
      perror("write");
      close(fpd);
      close(fps);
      exit(1);
    }
  }

  if (count < 0) {
    perror("read");
    close(fpd);
    close(fps);
    exit(1);
  }

  close(fpd);
  close(fps);

  return 0;
}
