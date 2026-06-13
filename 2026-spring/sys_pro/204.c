#include <ctype.h>
#include <stdio.h>
#include <string.h>

#define WORD_LEN 255
#define WORD_MAX 4095

struct word_count {
  char word[WORD_LEN];
  int cnt;
};

void print_freqword(char *str) {
  int word_num = 0;
  int len = strlen(str);
  struct word_count table[WORD_MAX];
  int left = -1;
  int i = 0;
  while (i <= len) {
    if (isalpha(str[i])) {
      if (left == -1) {
        left = i;
      }
    } else {
      if (left != -1) {
        // wordに現在の単語をコピー
        char word[WORD_LEN];
        int word_len = i - left;
        for (int iter = 0; iter < word_len; iter++) {
          word[iter] = tolower(str[left + iter]);
        }
        word[word_len] = '\0';
        int found = -1;
        for (int iter = 0; iter < word_num; iter++) {
          if (strcmp(word, table[iter].word) == 0) {
            found = iter;
            break;
          }
        }
        if (found >= 0) {
          table[found].cnt++;
        } else {
          strcpy(table[word_num].word, word);
          table[word_num].cnt = 1;
          word_num++;
        }
        left = -1;
      }
    }
    i++;
  }

  int max = 0;
  int p = 0;
  for (int iter = 0; iter < word_num; iter++) {
    if (max < table[iter].cnt) {
      max = table[iter].cnt;
      p = iter;
    }
  }
  printf("%s\n", table[p].word);
}

int main() {
  char str1[] = "One little, two little, three little Indians,\n"
                "Four little, five little, six little Indians,\n"
                "Seven little, eight little, nine little Indians,\n"
                "Ten little Indian boys.";
  char str2[] =
      "        Mary Had a Little Lamb\n\n"
      "Mary had a little lamb,\nIts fleece was white as snow;\n"
      "And everywhere that Mary went,\nThe lamb was sure to go.\n\n"
      "It followed her to school one day,\nWhich was against the rule;\n"
      "It made the children laugh and play,\nTo see a lamb at school.\n";

  print_freqword(str1); // "little"
  print_freqword(str2); // "lamb"

  return 0;
}
