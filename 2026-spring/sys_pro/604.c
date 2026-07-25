#include "./coins-syspro.c"
#include <stdio.h>  /* fprintf() */
#include <stdlib.h> /* exit() */

extern void http_send_request(char *host, char *file, FILE *out);
extern void recieve_response(FILE *in);

int main(int argc, char *argv[]) {
  char *host, *file;
  int port;
  int sock;
  FILE *in, *out;
  if (argc != 4) {
    fprintf(stderr, "Usage: %s host file\n", argv[0]);
    exit(1);
  }
  host = argv[1];
  port = strtol(argv[2], 0, 10);
  file = argv[3];
  sock = tcp_connect(host, port);
  if (sock < 0) {
    fprintf(stderr, "tcp_connect()\n");
    return (1);
  }
  if (fdopen_sock(sock, &in, &out) < 0) {
    fprintf(stderr, "%d", fdopen_sock(sock, &in, &out));
    // fprintf(stderr, "fdopen() \n");
    close(sock);
    return (1);
  }
  http_send_request(host, file, out);
  recieve_response(in);

  close(sock);
  return 0;
}

void http_send_request(char *host, char *file, FILE *out) { /*2026*/
  fprintf(out, "GET %s HTTP/1.0\r\n", file);
  fprintf(out, "Host: %s\r\n", host);
  fprintf(out, "\r\n");
}

void recieve_response(FILE *in) {
  char buf[1024];
  while (fgets(buf, sizeof(buf), in) != NULL) {
    fprintf(stdout, "%s", buf);
  }
}
