#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

static void receive_token(int fd) {
  char token;

  if (read(fd, &token, 1) != 1) {
    perror("read");
    exit(EXIT_FAILURE);
  }
}

static void send_token(int fd) {
  char token = 0;

  if (write(fd, &token, 1) != 1) {
    perror("write");
    exit(EXIT_FAILURE);
  }
}

int main(int argc, char *argv[]) {
  int child_to_parent[2], parent_to_child[2];
  long count;
  char *end;
  pid_t pid;
  int status;

  if (argc != 2) {
    fprintf(stderr, "usage: %s count\n", argv[0]);
    return EXIT_FAILURE;
  }
  errno = 0;
  count = strtol(argv[1], &end, 10);
  if (errno != 0 || *end != '\0' || count < 0) {
    fprintf(stderr, "count must be a nonnegative integer\n");
    return EXIT_FAILURE;
  }

  if (pipe(child_to_parent) < 0 || pipe(parent_to_child) < 0) {
    perror("pipe");
    return EXIT_FAILURE;
  }
  pid = fork();
  if (pid < 0) {
    perror("fork");
    return EXIT_FAILURE;
  }

  if (pid == 0) {
    close(child_to_parent[0]);
    close(parent_to_child[1]);
    for (long i = 0; i < count; i += 2) {
      putchar('0' + (i / 2) % 10);
      fflush(stdout);
      if (i + 1 < count) {
        send_token(child_to_parent[1]);
      }
      if (i + 2 < count) {
        receive_token(parent_to_child[0]);
      }
    }
    close(child_to_parent[1]);
    close(parent_to_child[0]);
    _exit(EXIT_SUCCESS);
  }

  close(child_to_parent[1]);
  close(parent_to_child[0]);
  for (long i = 1; i < count; i += 2) {
    receive_token(child_to_parent[0]);
    putchar('a' + (i / 2) % 26);
    fflush(stdout);
    if (i + 1 < count) {
      send_token(parent_to_child[1]);
    }
  }
  close(child_to_parent[0]);
  close(parent_to_child[1]);
  if (waitpid(pid, &status, 0) < 0) {
    perror("waitpid");
    return EXIT_FAILURE;
  }
  putchar('\n');
  return EXIT_SUCCESS;
}
