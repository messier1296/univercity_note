#include <stdio.h>
#include <stdlib.h>

#define M 30
#define N 1000

int main(void) {
  int array[N];
  srand(1);

  for (int i = 0; i < N; i++) {
    int j = rand();
    array[i] = 0 + (j * (M + 1.0) / (RAND_MAX + 1.0));
    printf("%d,", array[i]);
  }
  printf("\n \n");
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < array[i]; j++) {
      printf("*");
    }
    printf("\n");
  }
}
