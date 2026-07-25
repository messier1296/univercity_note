#define _POSIX_C_SOURCE 200809L

/* 709.c -- IPアドレスによるアクセス制御が可能なHTTPサーバ */

#include "coins-syspro.c"

#include <arpa/inet.h>
#include <stdint.h>

#define BUFFERSIZE 1024
#define IPV4_NETMASK_23 0xfffffe00U
#define COINS_IPV4_230 0x829ee600U
#define COINS_IPV4_222 0x829ede00U

static void http_server(int portno, int ip_version);
static void http_receive_request_and_send_reply(int com, int allowed);
static int http_receive_request(FILE *in, char *filename, size_t size);
static void http_send_reply(char *filename, FILE *out);
static void http_send_error(FILE *out, int status, char *reason);
static int peer_is_allowed(int com);
static int sockaddr_is_allowed(struct sockaddr_storage *peer);
static int ipv4_is_allowed(uint32_t address);
static char *content_type(char *filename);

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
    ip_version = 46;
  http_server(portno, ip_version);
  return 0;
}

static void http_server(int portno, int ip_version) {
  int acc, com;

  acc = tcp_acc_port(portno, ip_version);
  if (acc < 0)
    exit(1);
  tcp_sockaddr_print(acc);
  while (1) {
    printf("[%d] accepting incoming connections (fd==%d) ...\n", getpid(), acc);
    if ((com = accept(acc, 0, 0)) < 0) {
      perror("accept");
      exit(1);
    }
    printf("[%d] connection (fd==%d) from ", getpid(), com);
    tcp_peeraddr_print(com);
    http_receive_request_and_send_reply(com, peer_is_allowed(com));
  }
}

static void http_receive_request_and_send_reply(int com, int allowed) {
  char filename[BUFFERSIZE];
  FILE *in, *out;
  int valid;

  if (fdopen_sock(com, &in, &out) < 0) {
    perror("fdopen_sock");
    close(com);
    return;
  }
  valid = http_receive_request(in, filename, sizeof(filename));
  if (!allowed) {
    printf("[%d] access denied\n", getpid());
    http_send_error(out, 403, "Forbidden");
  } else if (valid) {
    http_send_reply(filename, out);
  } else {
    http_send_error(out, 400, "Bad Request");
  }
  printf("[%d] Replied\n", getpid());
  fclose(in);
  fclose(out);
}

static int http_receive_request(FILE *in, char *filename, size_t size) {
  char requestline[BUFFERSIZE], rheader[BUFFERSIZE];
  char **vec;
  int count;
  int required;

  if (fgets(requestline, sizeof(requestline), in) == NULL) {
    printf("No request line.\n");
    return 0;
  }
  chomp(requestline);
  printf("requestline is [%s]\n", requestline);
  while (fgets(rheader, sizeof(rheader), in) != NULL) {
    chomp(rheader);
    if (strcmp(rheader, "") == 0)
      break;
    printf("Ignored: %s\n", rheader);
  }

  if (strchr(requestline, '<') != NULL || strstr(requestline, "..") != NULL) {
    printf("Dangerous request line found.\n");
    return 0;
  }
  if (string_split(requestline, ' ', &count, &vec) < 0) {
    perror("string_split");
    exit(1);
  }
  if (count != 3 || strcmp(vec[0], "GET") != 0 ||
      (strcmp(vec[2], "HTTP/1.0") != 0 && strcmp(vec[2], "HTTP/1.1") != 0)) {
    free_string_vector(count, vec);
    return 0;
  }
  required = snprintf(filename, size, "%s", vec[1]);
  free_string_vector(count, vec);
  if (required < 0 || (size_t)required >= size)
    return 0;
  return 1;
}

static void http_send_reply(char *filename, FILE *out) {
  char path[BUFFERSIZE], buffer[BUFFERSIZE];
  char *type;
  FILE *file;
  size_t size;
  int required;

  type = content_type(filename);
  if (type == NULL) {
    http_send_error(out, 400, "Bad Request");
    return;
  }
  required = snprintf(path, sizeof(path), ".%s", filename);
  if (required < 0 || (size_t)required >= sizeof(path)) {
    http_send_error(out, 400, "Bad Request");
    return;
  }
  file = fopen(path, "rb");
  if (file == NULL) {
    http_send_error(out, 404, "Not Found");
    return;
  }

  fprintf(out,
          "HTTP/1.0 200 OK\r\n"
          "Content-Type: %s\r\n"
          "\r\n",
          type);
  while ((size = fread(buffer, 1, sizeof(buffer), file)) > 0)
    fwrite(buffer, 1, size, out);
  fclose(file);
}

static void http_send_error(FILE *out, int status, char *reason) {
  fprintf(out,
          "HTTP/1.0 %d %s\r\n"
          "Content-Type: text/html\r\n"
          "\r\n"
          "<html><head></head><body>%d %s</body></html>\n",
          status, reason, status, reason);
}

static int ipv4_is_allowed(uint32_t address) {
  return (address & IPV4_NETMASK_23) == COINS_IPV4_230 ||
         (address & IPV4_NETMASK_23) == COINS_IPV4_222;
}

static int peer_is_allowed(int com) {
  struct sockaddr_storage peer;
  socklen_t peer_size = sizeof(peer);

  if (getpeername(com, (struct sockaddr *)&peer, &peer_size) < 0) {
    perror("getpeername");
    return 0;
  }
  return sockaddr_is_allowed(&peer);
}

static int sockaddr_is_allowed(struct sockaddr_storage *peer) {
  static const unsigned char allowed_ipv6_prefix[7] = {0x20, 0x01, 0x02, 0xf8,
                                                       0x00, 0x3a, 0x17};

  if (peer->ss_family == AF_INET) {
    struct sockaddr_in *peer4 = (struct sockaddr_in *)peer;
    return ipv4_is_allowed(ntohl(peer4->sin_addr.s_addr));
  }
  if (peer->ss_family == AF_INET6) {
    struct sockaddr_in6 *peer6 = (struct sockaddr_in6 *)peer;
    unsigned char *address = peer6->sin6_addr.s6_addr;

    if (IN6_IS_ADDR_V4MAPPED(&peer6->sin6_addr)) {
      uint32_t address4;
      memcpy(&address4, &address[12], sizeof(address4));
      return ipv4_is_allowed(ntohl(address4));
    }
    return memcmp(address, allowed_ipv6_prefix, sizeof(allowed_ipv6_prefix)) ==
           0;
  }
  return 0;
}

static char *content_type(char *filename) {
  char *extension = strrchr(filename, '.');

  if (extension == NULL)
    return NULL;
  if (strcmp(extension, ".html") == 0)
    return "text/html";
  if (strcmp(extension, ".txt") == 0 || strcmp(extension, ".text") == 0)
    return "text/plain";
  if (strcmp(extension, ".gif") == 0)
    return "image/gif";
  if (strcmp(extension, ".jpeg") == 0)
    return "image/jpeg";
  if (strcmp(extension, ".png") == 0)
    return "image/png";
  return NULL;
}
