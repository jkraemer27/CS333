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

  if(!argv[1]){
      printf(1, "\nNo argument provided!\n\nUse \"time [program]\"\n\n");
      strcpy(process, "time");
  }

  
  int begin = uptime();

  int pid = fork();
  if(pid > 0){
      //printf(1, "parent: child=%d\n", pid);
      pid = wait();

      //printf(1, "child %d is done\n", pid);
  }
  else if(pid == 0){
	  if(exec(argv[1], argv + 1) < 0){
	      printf(1,"%s is not a valid program\n", process);
	      exit();
	  }
      }

      else
	  printf(1,"fork error\n");

      int end = uptime();

      int total = (end - begin)/1000;
      int milli = (end - begin)%1000;


      printf(1, "%s%s\n",process, " executing...");
      
      if(milli < 10)
      printf(1, "%s ran in %d.00%d seconds\n\n",process, total, milli, " seconds");
      
      if(milli > 9 && milli < 100)
      printf(1, "%s ran in %d.0%d seconds\n\n",process, total, milli, " seconds");
      
      else
      printf(1, "%s ran in %d.%d seconds\n\n",process, total, milli, " seconds");





  exit();
}

#endif
