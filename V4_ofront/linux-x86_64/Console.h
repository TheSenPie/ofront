/* voc 2.1.0 [2023/05/14] for gcc LP64 on arch xtpa */

#ifndef Console__h
#define Console__h

#include "SYSTEM.h"




import void Console_Bool (BOOLEAN b);
import void Console_Char (CHAR ch);
import void Console_Flush (void);
import void Console_Hex (INT32 i);
import void Console_Int (INT64 i, INT64 n);
import void Console_Ln (void);
import void Console_Read (CHAR *ch);
import void Console_ReadLine (CHAR *line, ADDRESS line__len);
import void Console_String (CHAR *s, ADDRESS s__len);
import void *Console__init(void);


#endif // Console
