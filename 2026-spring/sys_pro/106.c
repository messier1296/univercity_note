#include <stdio.h>
#include <stdlib.h>

#define N 1000
#define SEED 1
#define DEBUG_LIMIT 8

int original[N];
int quick_data[N];
int bubble_data[N];
long long quick_compare = 0;
long long bubble_compare = 0;
int debug_count = 0;

void print_head(int data[]) {
  int i;

  for (i = 0; i < 10; i++) {
    printf("%d ", data[i]);
  }
  printf("...\n");
}

void make_data(void) {
  int i;

  srand(SEED);
  for (i = 0; i < N; i++) {
    original[i] = rand() % 100000;
    quick_data[i] = original[i];
    bubble_data[i] = original[i];
  }
}

void swap(int data[], int i, int j) {
  int tmp = data[i];

  data[i] = data[j];
  data[j] = tmp;
}

void quick_sort(int data[], int left, int right) {
  int i = left;
  int j = right;
  int pivot = data[(left + right) / 2];

  if (left >= right) {
    return;
  }

  if (debug_count < DEBUG_LIMIT) {
    printf("quick debug %d: left=%d right=%d pivot=%d\n", debug_count, left,
           right, pivot);
    debug_count++;
  }

  while (i <= j) {
    while (quick_compare++, data[i] < pivot) {
      i++;
    }
    while (quick_compare++, data[j] > pivot) {
      j--;
    }
    if (i <= j) {
      swap(data, i, j);
      i++;
      j--;
    }
  }

  quick_sort(data, left, j);
  quick_sort(data, i, right);
}

void bubble_sort(int data[]) {
  int i, j;

  for (i = 0; i < N - 1; i++) {
    if (i < 5) {
      printf("bubble debug %d: ", i);
      print_head(data);
    }
    for (j = 0; j < N - 1 - i; j++) {
      bubble_compare++;
      if (data[j] > data[j + 1]) {
        swap(data, j, j + 1);
      }
    }
  }
}

int is_sorted(int data[]) {
  int i;

  for (i = 1; i < N; i++) {
    if (data[i - 1] > data[i]) {
      return 0;
    }
  }
  return 1;
}

int same_data(int a[], int b[]) {
  int i;

  for (i = 0; i < N; i++) {
    if (a[i] != b[i]) {
      return 0;
    }
  }
  return 1;
}

int main(void) {
  make_data();

  printf("N = %d\n", N);
  printf("seed = %d\n", SEED);
  printf("before: ");
  print_head(original);

  printf("\nquick sort\n");
  quick_sort(quick_data, 0, N - 1);
  printf("quick result: ");
  print_head(quick_data);
  printf("quick sorted: %s\n", is_sorted(quick_data) ? "yes" : "no");
  printf("quick compare: %lld\n", quick_compare);

  printf("\nbubble sort\n");
  bubble_sort(bubble_data);
  printf("bubble result: ");
  print_head(bubble_data);
  printf("bubble sorted: %s\n", is_sorted(bubble_data) ? "yes" : "no");
  printf("bubble compare: %lld\n", bubble_compare);

  printf("\nsame result: %s\n",
         same_data(quick_data, bubble_data) ? "yes" : "no");
  return 0;
}
