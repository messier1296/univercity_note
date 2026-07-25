
/*
  coins-syspro.c -- 情報科学類の授業「システムプログラム」で使うライブラリ
  ~yas/syspro/ipc/coins-syspro.c
*/
#include <ctype.h> /* isdigit() */
#include <netdb.h> /* getnameinfo() */
#include <stdio.h>
#include <stdlib.h>     /* malloc(), free() */
#include <string.h>     /* memcpy() */
#include <sys/socket.h> /* socket(), getnameinfo() */
#include <sys/types.h>  /* socket() */
#include <unistd.h>     /* gethostname() */

#define PORTNO_BUFSIZE 30
#define SOCKADDR_PRINT_BUFSIZE 1024
#define PRINT_MY_HOST_PORT_HOST_NAME_MAX 256

extern int tcp_connect(char *server, int portno);
extern void print_my_host_port(int portno);
extern void tcp_sockaddr_print(int com);
extern void tcp_peeraddr_print(int com);
extern void sockaddr_print(struct sockaddr *addrp, socklen_t addr_len);
extern int tcp_acc_port(int portno, int pf);
extern int fdopen_sock(int sock, FILE **inp, FILE **outp);
extern char *chomp(char *str);
extern int string_split(char *str, char del, int *countp, char ***vecp);
extern void free_string_vector(int qc, char **vec);
extern int countchr(char *s, char c);
extern char *get_query_string();
extern char *read_query_string();
extern void safe_printenv(char *name);
extern void safe_print_string(char *str);
extern char *html_escape(char *str);
extern char *decode_url(char *str);
extern char *getparam(int qc, char *qv[], char *name);

int tcp_connect(char *server, int portno) {
  struct addrinfo hints, *ai, *p;
  char portno_str[PORTNO_BUFSIZE];
  int s, err;
  snprintf(portno_str, sizeof(portno_str), "%d", portno);
  memset(&hints, 0, sizeof(hints));
  hints.ai_socktype = SOCK_STREAM;
  if ((err = getaddrinfo(server, portno_str, &hints, &ai))) {
    fprintf(stderr, "unknown server %s (%s)\n", server, gai_strerror(err));
    goto error0;
  }
  for (p = ai; p; p = p->ai_next) {
    if ((s = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) < 0) {
      perror("socket");
      goto error1;
    }
    if (connect(s, p->ai_addr, p->ai_addrlen) >= 0) {
      break;
    } else {
      close(s);
    }
  }
  freeaddrinfo(ai);
  return (s);
error1:
  freeaddrinfo(ai);
error0:
  return (-1);
}

void print_my_host_port(int portno) {
  char hostname[PRINT_MY_HOST_PORT_HOST_NAME_MAX + 1];

  gethostname(hostname, PRINT_MY_HOST_PORT_HOST_NAME_MAX);
  hostname[PRINT_MY_HOST_PORT_HOST_NAME_MAX] = 0;
  printf("run telnet %s %d \n", hostname, portno);
}

void tcp_sockaddr_print(int com) {
  struct sockaddr_storage addr;
  socklen_t addr_len; /* macOS: __uint32_t, Linux: unsigned int */

  addr_len = sizeof(addr);
  if (getsockname(com, (struct sockaddr *)&addr, &addr_len) < 0) {
    perror("tcp_peeraddr_print");
    return;
  }
  sockaddr_print((struct sockaddr *)&addr, addr_len);
  printf("\n");
}

void tcp_peeraddr_print(int com) {
  struct sockaddr_storage addr;
  socklen_t addr_len; /* macOS: __uint32_t, Linux: unsigned int */

  addr_len = sizeof(addr);
  if (getpeername(com, (struct sockaddr *)&addr, &addr_len) < 0) {
    perror("tcp_peeraddr_print");
    return;
  }
  sockaddr_print((struct sockaddr *)&addr, addr_len);
  printf("\n");
}

void sockaddr_print(struct sockaddr *addrp, socklen_t addr_len) {
  char host[SOCKADDR_PRINT_BUFSIZE];
  char port[SOCKADDR_PRINT_BUFSIZE];

  if (getnameinfo(addrp, addr_len, host, sizeof(host), port, sizeof(port),
                  NI_NUMERICHOST | NI_NUMERICSERV) < 0)
    return;
  if (addrp->sa_family == PF_INET)
    printf("%s:%s", host, port);
  else
    printf("[%s]:%s", host, port);
}

int tcp_acc_port(int portno, int ip_version) {
  struct addrinfo hints, *ai;
  char portno_str[PORTNO_BUFSIZE];
  int err, s, on, pf;

  switch (ip_version) {
  case 4:
    pf = PF_INET;
    break;
  case 6:
#if !defined(IPV6_V6ONLY)
    fprintf(stderr, "Sorry, IPV6_V6ONLY is not supported in this system.\n");
    goto error0;
#endif /*IPV6_V6ONLY*/
    pf = PF_INET6;
    break;
  case 0:
  case 46:
  case 64:
    pf = PF_INET6; /* pf = 0; in macOS */
    break;
  default:
    fprintf(stderr, "bad IP version: %d.  4 or 6 is allowed.\n", ip_version);
    goto error0;
  }
  snprintf(portno_str, sizeof(portno_str), "%d", portno);
  memset(&hints, 0, sizeof(hints));
  ai = NULL;
  hints.ai_family = pf;
  hints.ai_flags = AI_PASSIVE;
  hints.ai_socktype = SOCK_STREAM;
  if ((err = getaddrinfo(NULL, portno_str, &hints, &ai))) {
    fprintf(stderr, "bad portno %d? (%s)\n", portno, gai_strerror(err));
    goto error0;
  }
  if ((s = socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol)) < 0) {
    perror("socket");
    goto error1;
  }

#ifdef IPV6_V6ONLY
  if (ai->ai_family == PF_INET6 && ip_version == 6) {
    on = 1;
    if (setsockopt(s, IPPROTO_IPV6, IPV6_V6ONLY, &on, sizeof(on)) < 0) {
      perror("setsockopt(,,IPV6_V6ONLY)");
      goto error1;
    }
  }
#endif /*IPV6_V6ONLY*/

  if (bind(s, ai->ai_addr, ai->ai_addrlen) < 0) {
    perror("bind");
    fprintf(stderr, "Port number %d\n", portno);
    goto error2;
  }
  on = 1;
  if (setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) < 0) {
    perror("setsockopt(,,SO_REUSEADDR)");
    goto error2;
  }
  if (listen(s, 5) < 0) {
    perror("listen");
    goto error2;
  }
  freeaddrinfo(ai);
  return (s);

error2:
  close(s);
error1:
  freeaddrinfo(ai);
error0:
  return (-1);
}

int fdopen_sock(int sock, FILE **inp, FILE **outp) {
  int sock2;

  if ((sock2 = dup(sock)) < 0) {
    return (-1);
  }
  if ((*inp = fdopen(sock2, "r")) == NULL) {
    close(sock2);
    return (-2);
  }
  if ((*outp = fdopen(sock, "w")) == NULL) {
    fclose(*inp);
    *inp = 0;
    return (-3);
  }
  setvbuf(*outp, (char *)NULL, _IONBF, 0);
  return (0);
}

char *chomp(char *str) {
  int len;

  len = strlen(str);
  if (len >= 2 && str[len - 2] == '\r' && str[len - 1] == '\n') {
    str[len - 2] = str[len - 1] = 0;
  } else if (len >= 1 && (str[len - 1] == '\r' || str[len - 1] == '\n')) {
    str[len - 1] = 0;
  }
  return (str);
}

int string_split(char *str, char del, int *countp, char ***vecp) {
  char **vec;
  int count_max, i, len;
  char *s, *p;

  if (str == 0)
    return (-1);
  count_max = countchr(str, del) + 1;
  vec = malloc(sizeof(char *) * (count_max + 1));
  if (vec == 0)
    return (-1);

  for (i = 0; i < count_max; i++) {
    while (*str == del)
      str++;
    if (*str == 0)
      break;
    for (p = str; *p != del && *p != 0; p++)
      continue;
    /* *p == del || *p=='\0' */
    len = p - str;
    s = malloc(len + 1);
    if (s == 0) {
      int j;
      for (j = 0; j < i; j++) {
        free(vec[j]);
        vec[j] = 0;
      }
      free(vec);
      return (-1);
    }
    memcpy(s, str, len);
    s[len] = 0;
    vec[i] = s;
    str = p;
  }
  vec[i] = 0;
  *countp = i;
  *vecp = vec;
  return (i);
}

void free_string_vector(int qc, char **vec) {
  int i;
  for (i = 0; i < qc; i++) {
    if (vec[i] == NULL)
      break;
    free(vec[i]);
  }
  free(vec);
}

int countchr(char *s, char c) {
  int count;
  for (count = 0; *s; s++)
    if (*s == c)
      count++;
  return (count);
}

char *get_query_string() {
  char *request_method, *query_string;
  request_method = getenv("REQUEST_METHOD");
  if (request_method == 0)
    return (0);
  else if (strcmp(request_method, "GET") == 0) {
    query_string = getenv("QUERY_STRING");
    if (query_string == 0)
      return (0);
    else
      return (strdup(query_string));
  } else if (strcmp(request_method, "POST") == 0) {
    return (read_query_string());
  } else {
    printf("Unknown method: ");
    safe_print_string(request_method);
    printf("\n");
    return (0);
  }
}

char *read_query_string() {
  int clen;
  char *content_length;
  char *buf;

  content_length = getenv("CONTENT_LENGTH");
  if (content_length == 0) {
    return (0);
  } else {
    clen = strtol(content_length, 0, 10);
    buf = malloc(clen + 1);
    if (buf == 0) {
      printf("read_query_string(): no memory\n");
      exit(-1);
    }
    if (read(0, buf, clen) != clen) {
      printf("read error.\n");
      exit(-1);
    }
    buf[clen] = 0;
    return (buf);
  }
}

void safe_printenv(char *name) {
  char *val;
  char *safe_val;

  printf("%s=", name);
  val = getenv(name);
  safe_print_string(val);
  printf("\n");
}

void safe_print_string(char *str) {
  char *safe_str;

  if (str == 0) {
    printf("(null)");
    return;
  }
  safe_str = html_escape(str);
  if (safe_str == 0) {
    printf("(no memory)");
  } else {
    printf("%s", safe_str);
    free(safe_str);
  }
}

char *html_escape(char *str) {
  int len;
  char c, *tmp, *p, *res;

  len = strlen(str);
  tmp = malloc(len * 6 + 1);
  if (tmp == 0)
    return (0);
  p = tmp;
  while ((c = *str++)) {
    switch (c) {
    case '&':
      memcpy(p, "&amp;", 5);
      p += 5;
      break;
    case '<':
      memcpy(p, "&lt;", 4);
      p += 4;
      break;
    case '>':
      memcpy(p, "&gt;", 4);
      p += 4;
      break;
    case '"':
      memcpy(p, "&quot;", 6);
      p += 6;
      break;
    default:
      *p = c;
      p++;
      break;
    }
  }
  *p = 0;
  res = strdup(tmp);
  free(tmp);
  return (res);
}

char *decode_url(char *str) {
  int len;
  char c, *tmp, *p, *res;

  len = strlen(str);
  tmp = malloc(len + 1);
  if (tmp == 0)
    return (0);
  p = tmp;

  while (*str) {
    if (*str == '%' && isxdigit(*(str + 1)) && isxdigit(*(str + 2))) {
      char hexstr[3];
      hexstr[0] = *(str + 1);
      hexstr[1] = *(str + 2);
      hexstr[2] = 0;
      c = strtol(hexstr, 0, 16);
      *p++ = c;
      str += 3;
    } else if (*str == '+') {
      *p++ = ' ';
      str++;
    } else {
      *p++ = *str;
      str++;
    }
  }
  *p = 0;
  res = strdup(tmp);
  free(tmp);
  return (res);
}

char *getparam(int qc, char *qv[], char *name) {
  int i;
  size_t len;

  len = strlen(name);
  for (i = 0; i < qc; i++) {
    if (strncmp(qv[i], name, len) == 0 && qv[i][len] == '=') {
      return (&qv[i][len + 1]);
    }
  }
  return (NULL);
}
