#include <stdio.h>
#include <ctype.h>

int main(){
  int cnt = 0;

  int c;
  while ((c = getchar()) != EOF ){
    cnt++;
    if (c == ' '){
      putchar('_');
    }
    else if (c == 0x09){
      printf("[TAB]");
    }
    else if (islower(c)){
      putchar(toupper(c));
    }
    else {
      cnt--;
      putchar(c);
    }
  }
  fprintf(stderr, "%d characters translated.\n",cnt);
  return 0;
}
