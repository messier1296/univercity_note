/*
  http-server-.c -- 常に同じ内容を返す HTTP サーバ(forkなし版)
  ~yas/syspro/ipc/http-server.c
*/

#include "coins-syspro.c"

extern void http_server(int portno, int ip_version);
extern void http_receive_request_and_send_reply(int com);
extern int http_receive_request(FILE *in);
extern void http_send_reply(FILE *out);
extern void http_send_reply_bad_request(FILE *out);
extern void print_my_host_port_http(int portno);

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
  print_my_host_port_http(portno);
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

#define BUFFERSIZE 1024

void http_receive_request_and_send_reply(int com) {
  FILE *in, *out;

  if (fdopen_sock(com, &in, &out) < 0) {
    perror("fdooen()");
    exit(-1);
  }
  if (http_receive_request(in)) {
    http_send_reply(out);
  } else {
    http_send_reply_bad_request(out);
  }
  printf("[%d] Replied\n", getpid());
  fclose(in);
  fclose(out);
}

int http_receive_request(FILE *in) {
  char requestline[BUFFERSIZE];
  char rheader[BUFFERSIZE];

  if (fgets(requestline, BUFFERSIZE, in) <= 0) {
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
  return (1);
}

void http_send_reply(FILE *out) {
  fprintf(out, "HTTP/1.0 200 OK\r\n"
               "Content-Type: text/html\r\n"
               "\r\n");
  fprintf(out, "<html><head></head><body>hello.</body></html>\n");
}

void http_send_reply_bad_request(FILE *out) {
  fprintf(out, "HTTP/1.0 400 Bad Request\r\n"
               "Content-Type: text/html\r\n"
               "\r\n");
  fprintf(out, "<html><head></head><body>400 Bad Request</body></html>\n");
}

#define HOST_NAME_MAX 256
void print_my_host_port_http(int portno) {
  char hostname[HOST_NAME_MAX + 1];

  gethostname(hostname, HOST_NAME_MAX);
  hostname[HOST_NAME_MAX] = 0;
  printf("open http://%s:%d/index.html\n", hostname, portno);
}
