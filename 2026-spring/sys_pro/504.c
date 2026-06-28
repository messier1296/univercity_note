#define _POSIX_C_SOURCE 200809L

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static void handler(int signum, siginfo_t *info, void *context) {
  (void)context;

  if (signum == SIGFPE) {
    printf("zero division occurred\n");
  } else if (signum == SIGSEGV) {
    printf("invalid memory access occurred: address=%p\n", info->si_addr);
  } else if (signum == SIGWINCH) {
    printf("window size changed\n");
  }
  fflush(stdout);
  _Exit(EXIT_SUCCESS);
}

int main(int argc, char *argv[]) {
  struct sigaction action;
  int mode;

  if (argc != 2) {
    fprintf(stderr, "usage: %s 0|1|2\n", argv[0]);
    return EXIT_FAILURE;
  }

  sigemptyset(&action.sa_mask);
  action.sa_sigaction = handler;
  action.sa_flags = SA_SIGINFO;
  if (sigaction(SIGFPE, &action, NULL) < 0 ||
      sigaction(SIGSEGV, &action, NULL) < 0 ||
      sigaction(SIGWINCH, &action, NULL) < 0) {
    perror("sigaction");
    return EXIT_FAILURE;
  }

  mode = atoi(argv[1]);
  if (mode == 0) {
    volatile int one = 1;
    volatile int zero = atoi(argv[1]);
    volatile int result = one / zero;
    printf("%d\n", result);
  } else if (mode == 1) {
    volatile int *p = (int *)0x12345;
    *p = 1;
  } else if (mode == 2) {
    pause();
  } else {
    fprintf(stderr, "argument must be 0, 1, or 2\n");
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
