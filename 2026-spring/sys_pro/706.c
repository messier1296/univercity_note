#include "coins-syspro.c"
#include <stdio.h>
#define BUFFERSIZE 1024

extern int http_receive_request(FILE *in, char *filename, size_t size);
extern void http_send_reply(FILE *out, char *filename);
extern void http_send_reply_bad_request(FILE *out);
extern void http_send_reply_not_found(FILE *out);
extern void http_server(int portno, int ip_version);
extern void http_receive_request_and_send_reply(int com);

int main(int argc, char *argv[]) {
  int portno, ip_version;

  if (!(argc == 2 || argc == 3)) {
    fprintf(stderr, "Usage: %s portno {ipversion}\n", argv[0]);
    exit(1);
  }
  portno = strtol(argv[1], 0, 10);
  if (argc == 3)
    ip_version = strtol(argv[2], 0, 10);
  else
    ip_version = 46; /* Both IPv4 and IPv6 by default */
  http_server(portno, ip_version);
}
void http_server(int portno, int ip_version) {
  int acc, com;

  acc = tcp_acc_port(portno, ip_version);
  if (acc < 0)
    exit(-1);
  tcp_sockaddr_print(acc);
  while (1) {
    printf("[%d] accepting incoming connections (fd==%d) ...\n", getpid(), acc);
    if ((com = accept(acc, 0, 0)) < 0) {
      perror("accept");
      exit(-1);
    }
    printf("[%d] connection (fd==%d) from ", getpid(), com);
    tcp_peeraddr_print(com);
    http_receive_request_and_send_reply(com);
  }
}

void http_receive_request_and_send_reply(int com) {
  FILE *in, *out;
  char filename[BUFFERSIZE];

  if (fdopen_sock(com, &in, &out) < 0) {
    perror("fdooen()");
    exit(-1);
  }
  if (http_receive_request(in, filename, BUFFERSIZE)) {
    http_send_reply(out, filename);
  } else {
    http_send_reply_bad_request(out);
  }
  printf("[%d] Replied\n", getpid());
  fclose(in);
  fclose(out);
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
void http_send_reply(FILE *out, char *filename) /* 2026 */
{
  /* 後で課題(705)に回答する人はこの関数をそのまま利用しなさい。 */
  char *ext;
  char path[BUFSIZ];
  int req;
  FILE *file;
  char buf[BUFSIZ];
  size_t n;

  ext = strrchr(filename, '.');
  if (ext == NULL) {
    http_send_reply_bad_request(out);
    return;
  } else if (strcmp(ext, ".html") == 0) {
    // printf("filename is [%s], and extention is [%s].\n", filename, ext);
    /*
     * "Change this" を含めてこの部分を修正する。
     * snprintf() 等でファイル名を作成する。
     * fopen()  等でファイルを開く。
     * ファイルが存在しなければ、http_send_reply_not_found()
     * でエラーを送信する。 ファイルが存在すれば、fread()
     * 等で読み、その内容をfwrite() 等で out に書き込み送信する。 fclose()
     * 等でファイルを閉じる。
     */
    req = snprintf(path, BUFSIZ, "./%s", filename);
    if (req >= BUFSIZ || req < 0) {
      http_send_reply_bad_request(out);
      return;
    }
    file = fopen(path, "r");
    if (file == NULL) {
      http_send_reply_not_found(out);
      return;
    }
    fprintf(out, "HTTP/1.0 200 OK\r\n");
    fprintf(out, "Content-Type: text/html\r\n");
    fprintf(out, "\r\n");
    while ((n = fread(buf, 1, BUFSIZ, file)) > 0) {
      fwrite(buf, 1, n, out);
    }
    fclose(file);
    return;
  } else {
    http_send_reply_bad_request(out);
    return;
  }
}

void http_send_reply_bad_request(FILE *out) {
  fprintf(out, "HTTP/1.0 400 Bad Request\r\n"
               "Content-Type: text/html\r\n"
               "\r\n");
  fprintf(out, "<html><head></head><body>400 Bad Request</body></html>\n");
}

void http_send_reply_not_found(FILE *out) {
  fprintf(out, "HTTP/1.0 404 Not Found\r\n"
               "Content-Type: text/html\r\n"
               "\r\n");
  fprintf(out, "<html><head></head><body>404 Not Found</body></html>\n");
}
