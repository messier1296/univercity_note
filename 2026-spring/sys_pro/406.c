#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  int input_fd, output_fd;

  if (argc != 3) {
    fprintf(stderr, "usage: %s input output\n", argv[0]);
    return EXIT_FAILURE;
  }

  input_fd = open(argv[1], O_RDONLY);
  if (input_fd < 0) {
    perror(argv[1]);
    return EXIT_FAILURE;
  }
  output_fd = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644);
  if (output_fd < 0) {
    perror(argv[2]);
    close(input_fd);
    return EXIT_FAILURE;
  }

  if (dup2(input_fd, STDIN_FILENO) < 0 ||
      dup2(output_fd, STDOUT_FILENO) < 0) {
    perror("dup2");
    close(input_fd);
    close(output_fd);
    return EXIT_FAILURE;
  }
  close(input_fd);
  close(output_fd);

  execlp("bc", "bc", (char *)NULL);
  perror("execlp");
  return EXIT_FAILURE;
}
