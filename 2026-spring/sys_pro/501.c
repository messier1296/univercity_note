#define _POSIX_C_SOURCE 200809L

#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

int main(void) {
  DIR *dir;
  struct dirent *entry;

  dir = opendir(".");
  if (dir == NULL) {
    perror("opendir");
    return EXIT_FAILURE;
  }

  while ((entry = readdir(dir)) != NULL) {
    struct stat st;

    if (stat(entry->d_name, &st) < 0) {
      perror(entry->d_name);
      closedir(dir);
      return EXIT_FAILURE;
    }
    printf("%s %lld\n", entry->d_name, (long long)st.st_size);
  }

  closedir(dir);
  return EXIT_SUCCESS;
}
