#define _POSIX_C_SOURCE 200809L

#include <ctype.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

static volatile sig_atomic_t timeout_occurred = 0;
static volatile sig_atomic_t interrupt_occurred = 0;

static void handler(int signum) {
  if (signum == SIGALRM) {
    timeout_occurred = 1;
  } else if (signum == SIGINT) {
    interrupt_occurred = 1;
  }
}

int mygetchar(unsigned int seconds) {
  struct sigaction alarm_action, int_action, old_alarm_action, old_int_action;
  int c;

  timeout_occurred = 0;
  interrupt_occurred = 0;

  sigemptyset(&alarm_action.sa_mask);
  alarm_action.sa_handler = handler;
  alarm_action.sa_flags = 0;
  if (sigaction(SIGALRM, &alarm_action, &old_alarm_action) < 0) {
    return -3;
  }

  sigemptyset(&int_action.sa_mask);
  int_action.sa_handler = handler;
  int_action.sa_flags = 0;
  if (sigaction(SIGINT, &int_action, &old_int_action) < 0) {
    sigaction(SIGALRM, &old_alarm_action, NULL);
    return -3;
  }

  clearerr(stdin);
  alarm(seconds);
  c = getchar();
  alarm(0);

  sigaction(SIGALRM, &old_alarm_action, NULL);
  sigaction(SIGINT, &old_int_action, NULL);

  if (c != EOF) {
    return c;
  }
  if (timeout_occurred) {
    return -2;
  }
  if (interrupt_occurred) {
    return -3;
  }
  if (feof(stdin)) {
    return -1;
  }
  return -3;
}

int main(int argc, char *argv[]) {
  int result;
  time_t now;

  if (argc != 2) {
    fprintf(stderr, "usage: %s seconds\n", argv[0]);
    return EXIT_FAILURE;
  }

  now = time(NULL);
  printf("before: %s", ctime(&now));
  result = mygetchar((unsigned int)atoi(argv[1]));
  now = time(NULL);
  printf("after: %s", ctime(&now));

  if (result >= 0 && isprint(result)) {
    printf("return: %d (%c)\n", result, result);
  } else {
    printf("return: %d\n", result);
  }

  return EXIT_SUCCESS;
}
