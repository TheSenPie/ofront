MODULE v4kernel;
	IMPORT Platform, Unix := LINUX64;

	TYPE
		RealTime = POINTER TO TimeDesc;
		TimeDesc = RECORD
			sec, min, hour, mday, mon, year, wday, isdst, zone, gmtoff: LONGINT
		END ;

		KeyCmd* = PROCEDURE;

	VAR

		(* input event handling *)
		readSet*, readySet*: Unix.FdSet;

		FKey*: ARRAY 16 OF KeyCmd;

	(* PROCEDURE -Aincludetime "#include <time.h>";

	PROCEDURE -localtime(VAR clock: HUGEINT): RealTime
			"(v4kernel_RealTime)localtime(clock)";

	PROCEDURE GetClock* (VAR t, d: LONGINT);
		VAR tv: LINUX64.Timeval; tz: LINUX64.Timezone; time: RealTime;
		s: HUGEINT;
	BEGIN
		LINUX64.Gettimeofday(tv, tz);
		s := tv.sec;
		time := localtime(s);
		t := time.sec + ASH(time.min, 6) + ASH(time.hour, 12);
		d := time.mday + ASH(time.mon+1, 5) + ASH(time.year MOD 100, 9); 
	END GetClock; *)

	(*PROCEDURE -sigsetjmp*(VAR env: Unix.JmpBuf; savemask: LONGINT): LONGINT
			"sigsetjmp(env, savemask)"; (* ormay be better __sigsetjmp *)

	PROCEDURE -siglongjmp*(VAR env:Unix. JmpBuf; val: LONGINT)
   		 "Kernel_CallTrapCleaners(); siglongjmp(env, val)";*)

	PROCEDURE GetClock* (VAR t, d: LONGINT);
	BEGIN
		Platform.GetClock(t, d)
	END GetClock;

	PROCEDURE SetClock* (t, d: LONGINT);
		VAR err: ARRAY 25 OF CHAR;
	BEGIN err := "not yet implemented"; HALT(99) END SetClock;

	PROCEDURE Select*(delay: LONGINT);
		VAR rs, ws, xs: Unix.FdSet; n: LONGINT; tv: Unix.Timeval;
	BEGIN
		rs := readSet;
		FOR n := 0 TO LEN(rs) - 1 DO ws[n] := {}; xs[n] := {}; readySet[n] := {} END;
		IF delay < 0 THEN delay := 0 END ;
		tv.sec := delay DIV 1000; tv.usec := delay MOD 1000 * 1000;
		n := Unix.select(LEN(rs) * 32, rs, ws, xs, tv);
		IF n >= 0 THEN readySet := rs END
	END Select;

END v4kernel.
