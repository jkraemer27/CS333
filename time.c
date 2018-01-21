#ifdef CS333_P2
#include "types.h"
#include "user.h"
#include "uproc.h"
#include "param.h"

int
main(int argc, char ** argv)
{
  char process[MAXPROC];

  strcpy(process, argv[1]);

  printf(1, "%s%s\n",argv[1], " executing...");
  
  int begin = uptime();

  //printf(1, "%s\t %d\n","Start time: ", begin);


  int pid = fork();
  if(pid > 0){
      //printf(1, "parent: child=%d\n", pid);
      pid = wait();
      //printf(1, "child %d is done\n", pid);
  }
  else if(pid ==0){
      //printf(1,"child: exiting\n");
      exit();
  }
      else{
	  //printf(1,"fork error\n");
      }

  exec("/bin/echo", argv);
 //execute the program


  int end = uptime();
  //printf(1, "%s\t %d\n","End time: ", end);

  int total = (end - begin)%1000;

  
  printf(1, "%s%d\n\n","Total time: .", total);
  exit();
}

#endif
