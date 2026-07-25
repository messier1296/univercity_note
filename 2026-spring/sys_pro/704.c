
/*
 * http-request-analyze.c -- HTTPのrequest lineを解析する(枠組みだけ、2026)
 * ~yas/syspro/ipc/http-request-analyze.c
 */

#include "coins-syspro.c"

extern int http_receive_request(FILE *in, char *filename, size_t size);

#define BUFFERSIZE 1024

int main(int argc, char *argv[]) {
  char filename[BUFFERSIZE];
  int res;

  if (argc != 1) {
    fprintf(stderr, "Usage: %s < request-filename\n", argv[0]);
    exit(1);
  }
  res = http_receive_request(stdin, filename, BUFFERSIZE);
  if (res)
    printf("filename is [%s].\n", filename);
  else
    printf("Bad request.\n");
}

int http_receive_request(FILE *in, char *filename, size_t size) /* 2026 */
{
  /* 後で課題(705)に回答する人はこの関数をそのまま利用しなさい。 */
  /* 内容を変更しなさい。*/
  char requestline[BUFFERSIZE];
  char rheader[BUFFERSIZE];

  snprintf(filename, size, "NOFILENAME");
  if (fgets(requestline, BUFFERSIZE, in) == NULL) {
    printf("No request line.\n");
    return (0);
  }
  chomp(requestline); /* remove \r\n */
  printf("requestline is [%s]\n", requestline);
  while (fgets(rheader, BUFFERSIZE, in)) {
    chomp(rheader); /* remove \r\n */
    if (strcmp(rheader, "") == 0)
      break;
    printf("Ignored: %s\n", rheader);
  }
  if (strchr(requestline, '<') || strstr(requestline, "..")) {
    printf("Dangerous request line found.\n");
    return (0);
  }
  int cnt;
  char **vec;
  if (string_split(requestline, ' ', &cnt, &vec) < 0) {
    printf("string_split failed");
    return (0);
  }
  if (cnt != 3) {
    free_string_vector(cnt, vec);
    return (0);
  }
  if (strcmp(vec[0], "GET") != 0) {
    free_string_vector(cnt, vec);
    return (0);
  }
  if (strcmp(vec[2], "HTTP/1.0") != 0 && strcmp(vec[2], "HTTP/1.1") != 0) {
    free_string_vector(cnt, vec);
    return (0);
  }
  snprintf(filename, size, "%s", vec[1]);
  free_string_vector(cnt, vec);
  return (1);
}
