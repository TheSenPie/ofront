MODULE v4kernel;
	IMPORT Platform;

	TYPE
		RealTime = POINTER TO TimeDesc;
		TimeDesc = RECORD
			sec, min, hour, mday, mon, year, wday, isdst, zone, gmtoff: LONGINT
		END ;

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


	PROCEDURE GetClock* (VAR t, d: LONGINT);
	BEGIN
		Platform.GetClock(t, d)
	END GetClock;

	PROCEDURE SetClock* (t, d: LONGINT);
		VAR err: ARRAY 25 OF CHAR;
	BEGIN err := "not yet implemented"; HALT(99) END SetClock;

END v4kernel.
