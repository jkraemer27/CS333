#ifdef CS333_P5
#include "types.h"
#include "user.h"
int
main(int argc, char ** argv)
{
  char file[16];
  int perm;

  if(!argv[2] || !argv[1]){
      printf(1, "\nIncorrect number of arguments provided!\n\nUse \"chown [permission] [program]\"\n\n");
      exit();
  }

  strcpy(file, argv[2]);

  perm = atoi(argv[1]);

  if(chown(file, perm) == -1)
      printf(1, "\nError\n");

  exit();
}

#endif
