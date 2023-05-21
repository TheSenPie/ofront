MODULE LINUX64;

IMPORT SYSTEM;
TYPE
	FdSet* = ARRAY 32 OF SET;
	Timeval* = RECORD
		sec*, usec*: HUGEINT;
	END;
VAR
	(* input event handling *)
	readSet*, readySet*: FdSet;

	PROCEDURE -AincludeSelect "#include <sys/select.h>";
	PROCEDURE -UnixSelect*(width: LONGINT; VAR readfds, writefds, exceptfds: FdSet; VAR timeout: Timeval): LONGINT
		"select(width, readfds, writefds, exceptfds, timeout)";

	PROCEDURE Select*(delay: LONGINT);
		VAR rs, ws, xs: FdSet; n: LONGINT; tv: Timeval;
	BEGIN
		rs := readSet;
		FOR n := 0 TO LEN(rs) - 1 DO ws[n] := {}; xs[n] := {}; readySet[n] := {} END;
		IF delay < 0 THEN delay := 0 END ;
		tv.sec := delay DIV 1000; tv.usec := delay MOD 1000 * 1000;
		n := UnixSelect(LEN(rs) * 32, rs, ws, xs, tv);
		IF n >= 0 THEN readySet := rs END
	END Select;
END LINUX64.
