/* voc 2.1.0 [2023/05/14] for gcc LP64 on arch xtpa */

#ifndef Args__h
#define Args__h

#include "SYSTEM.h"


import INT16 Args_argc;
import INT64 Args_argv;


import void Args_Get (INT16 n, CHAR *val, ADDRESS val__len);
import void Args_GetEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len);
import void Args_GetInt (INT16 n, INT32 *val);
import INT16 Args_Pos (CHAR *s, ADDRESS s__len);
import BOOLEAN Args_getEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len);
import void *Args__init(void);


#endif // Args
