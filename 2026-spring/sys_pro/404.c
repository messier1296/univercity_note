#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

extern char **environ;

int mysystem(const char *command) {
  pid_t pid;
  int status;

  pid = fork();
  if (pid < 0) {
    perror("fork");
    return 1;
  }
  if (pid == 0) {
    char *argv[] = {"sh", "-c", (char *)command, NULL};

    execve("/bin/sh", argv, environ);
    perror("execve");
    _exit(1);
  }

  if (waitpid(pid, &status, 0) < 0) {
    perror("waitpid");
    return 1;
  }
  return 0;
}

int main(void) {
  mysystem("printf 'apple\\nbanana\\napricot\\n' > fruits.txt");
  mysystem("cat fruit*.txt | grep '^a' | wc -l");
  mysystem("rm fruits.txt");
  return EXIT_SUCCESS;
}
