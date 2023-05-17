/* voc 2.1.0 [2023/05/14] for gcc LP64 on arch xtpa */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"
#include "Modules.h"
#include "Platform.h"

typedef
	CHAR (*Args_ArgPtr)[1024];

typedef
	Args_ArgPtr (*Args_ArgVec)[1024];


export INT16 Args_argc;
export INT64 Args_argv;


export void Args_Get (INT16 n, CHAR *val, ADDRESS val__len);
export void Args_GetEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len);
export void Args_GetInt (INT16 n, INT32 *val);
export INT16 Args_Pos (CHAR *s, ADDRESS s__len);
export BOOLEAN Args_getEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len);


void Args_Get (INT16 n, CHAR *val, ADDRESS val__len)
{
	Modules_GetArg(n, (void*)val, val__len);
}

void Args_GetInt (INT16 n, INT32 *val)
{
	Modules_GetIntArg(n, &*val);
}

INT16 Args_Pos (CHAR *s, ADDRESS s__len)
{
	__DUP(s, s__len, CHAR);
	__DEL(s);
	return Modules_ArgPos(s, s__len);
}

void Args_GetEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len)
{
	__DUP(var, var__len, CHAR);
	Platform_GetEnv(var, var__len, (void*)val, val__len);
	__DEL(var);
}

BOOLEAN Args_getEnv (CHAR *var, ADDRESS var__len, CHAR *val, ADDRESS val__len)
{
	__DUP(var, var__len, CHAR);
	__DEL(var);
	return Platform_getEnv(var, var__len, (void*)val, val__len);
}


export void *Args__init(void)
{
	__DEFMOD;
	__MODULE_IMPORT(Modules);
	__MODULE_IMPORT(Platform);
	__REGMOD("Args", 0);
/* BEGIN */
	Args_argc = Modules_ArgCount;
	Args_argv = Modules_ArgVector;
	__ENDMOD;
}
