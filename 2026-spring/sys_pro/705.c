
/*
 * http-response-html.c --
 * HTTPの応答を画面に表示する(.html専用、枠組みだけ、2026)
 * ~yas/syspro/ipc/http-response-html.c
 */

#include "coins-syspro.c"
#include <stdio.h>

extern void http_send_reply(FILE *out, char *filename);
extern void http_send_reply_bad_request(FILE *out);
extern void http_send_reply_not_found(FILE *out);

int main(int argc, char *argv[]) {
  char *filename;

  if (argc != 2) {
    fprintf(stderr, "Usage: %s filename\n", argv[0]);
    exit(1);
  }
  filename = argv[1];
  http_send_reply(stdout, filename);
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
    while ((n = fread(buf, 1, BUFSIZ, file)) < 0) {
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
