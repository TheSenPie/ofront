MODULE TestKernel;
	IMPORT v4kernel, Out;

	VAR
		a,b: LONGINT;

BEGIN
	v4kernel.GetClock(a, b);	
	Out.Int(a,0);
	Out.Ln;
	Out.Int(b,0);
	Out.Ln;		

END TestKernel.
