MODULE Fonts; (*JG 27.8.90/RC 9.7.91*)

	IMPORT X11, Display, SYSTEM, Platform, Files, Console, Args;

	CONST
		FontFileId = 0DBX;
		defaultMapFileName = "";
 
	TYPE
		Name* = ARRAY 32 OF CHAR;
		Font* = POINTER TO FontDesc;
		FontDesc* = RECORD
			name*: Name;
			height*, minX*, maxX*, minY*, maxY*: INTEGER;
			raster*: Display.Font;
			next: Font
		END;

	VAR
		Default*, First: Font; nofFonts: INTEGER;
		mapFileName: ARRAY 64 OF CHAR;
		Unit*: INTEGER; (* pixel size derived from options -u and -f *)

	PROCEDURE This* (name: ARRAY OF CHAR): Font;

		TYPE
			RunRec = RECORD beg, end: INTEGER END;
			BoxRec = RECORD dx, x, y, w, h: INTEGER END;

		VAR
			F: Font; raster: X11.Font;
			f: Files.File; R: Files.Rider;
			pixmap, pixmapX, pixmapDX, pixmapW, pixmapH, RasterBase, b, n, a: LONGINT;
			NofRuns, NofBoxes: INTEGER;
			k, l, m, w, h: INTEGER;
			ch: CHAR;
			run: ARRAY 16 OF RunRec;
			box: ARRAY 256 OF BoxRec;
			list, count: LONGINT;
			fileName: ARRAY 64 OF CHAR;
			rb: SYSTEM.PTR;
			end, adr: SYSTEM.ADDRESS; (* J. Templ, for checking valid bitmap addressing *)

	PROCEDURE Convert (from: ARRAY OF CHAR; VAR to: ARRAY OF CHAR);
		VAR f: Files.File; r: Files.Rider; src, dst: ARRAY 64 OF CHAR;

		PROCEDURE Name (VAR s: ARRAY OF CHAR);
			VAR ch: CHAR; i: INTEGER;
		BEGIN
			Files.Read (r, ch);
			WHILE ~r.eof & (ch < "#") DO Files.Read (r, ch) END ;
			i := 0;
			WHILE ~r.eof & (ch > "#") DO s[i] := ch; INC(i); Files.Read (r, ch) END  ;
			s[i] := 0X
		END Name;

	BEGIN
		f := Files.Old (mapFileName);
		IF f # NIL THEN
			Files.Set (r, f, 0); Files.Read (r, ch);
			REPEAT
				WHILE ~r.eof & (ch # "#") DO Files.Read (r, ch) END ;
				Name(src)
			UNTIL r.eof OR (src = "fontmapfile");
			Name(src); Name(dst);
			WHILE (src # "") & (src # from) DO Name(src); Name(dst) END;
			IF src = "" THEN COPY (from, to) ELSE COPY (dst, to) END
		ELSE COPY (from, to)
		END;
	END Convert;

	PROCEDURE DummyCh(m: INTEGER);
		VAR raster: X11.Font;
	BEGIN
		raster := SYSTEM.VAL(X11.Font, F.raster);
		raster.metrics[m].dx := 0;
		raster.metrics[m].x := 0;
		raster.metrics[m].y := 0;
		raster.metrics[m].p.x := 0;
		raster.metrics[m].p.y := 0;
		raster.metrics[m].p.w := 0;
		raster.metrics[m].p.h := 0
	END DummyCh;

	BEGIN F := First;
		LOOP
			IF F = NIL THEN EXIT END;
			IF name = F.name THEN EXIT END;
			F := F.next
		END;
		IF F = NIL THEN
			Convert (name, fileName);
			f := Files.Old(fileName);
			IF f # NIL THEN
				Files.Set(R, f, 0); Files.Read(R, ch);
				IF ch = FontFileId THEN
					Files.Read(R, ch); (*abstraction*)
					Files.Read(R, ch); (*family*)
					Files.Read(R, ch); (*variant*)
					NEW(F);
					Files.ReadInt(R, F.height);
					Files.ReadInt(R, F.minX); Files.ReadInt(R, F.maxX);
					Files.ReadInt(R, F.minY); Files.ReadInt(R, F.maxY);
					Files.ReadInt(R, NofRuns);
					NofBoxes := 0; k := 0;
					WHILE k # NofRuns DO
						Files.ReadInt(R, run[k].beg); Files.ReadInt(R, run[k].end);
						NofBoxes := NofBoxes + run[k].end - run[k].beg;
						INC(k)
					END;
					pixmapW := 0; l := 0;
					WHILE l # NofBoxes DO
						Files.ReadInt(R, box[l].dx);
						Files.ReadInt(R, box[l].x); Files.ReadInt(R, box[l].y);
						Files.ReadInt(R, box[l].w); Files.ReadInt(R, box[l].h);
						pixmapW := pixmapW + (box[l].w + 7) DIV 8;
						INC(l)
					END;
					pixmapH := F.maxY - F.minY;
					NEW(raster); F.raster := SYSTEM.VAL(Display.Font, raster);
					SYSTEM.NEW(rb, pixmapW*pixmapH);	(* temporary *)
					RasterBase := SYSTEM.VAL(LONGINT, rb);
					end := RasterBase + pixmapW*pixmapH;
					pixmapX := 0;
					k := 0; l := 0; m := 0;
					WHILE k < NofRuns DO
						WHILE m < run[k].beg DO DummyCh(m); INC(m) END;
						WHILE m < run[k].end DO
							raster.metrics[m].dx := box[l].dx;
							raster.metrics[m].x := box[l].x;
							raster.metrics[m].y := box[l].y;
							raster.metrics[m].p.x := pixmapX;
							raster.metrics[m].p.y := 0;
							w := box[l].w; raster.metrics[m].p.w := w;
							h := box[l].h; raster.metrics[m].p.h := h;
							pixmapDX := (w + 7) DIV 8;
							n := pixmapDX * h;
							a := RasterBase + pixmapX DIV 8;
							b := 0;
							WHILE b < n DO
								Files.Read(R, ch);
								adr := a + (h - 1 - b DIV pixmapDX)*pixmapW + b MOD pixmapDX;
								IF (adr >= RasterBase) & (adr < end) THEN SYSTEM.PUT(adr, ch)
								ELSE (* ignore; font Syntax10w.Scn.Fnt has bitmap data for characters 33-36 out of valid range *)
								END;
								INC(b)
							END;
							INC(l); INC(m);
							INC(pixmapX, 8*pixmapDX)
						END;
						INC(k)
					END;
					WHILE m < 256 DO DummyCh(m); INC(m) END;
					pixmap := X11.RasterToPixmap(RasterBase, 8*pixmapW, pixmapH);
					m := 0;
					WHILE m < 256 DO raster.metrics[m].p.pixmap := pixmap; INC(m) END ;
                  	COPY(name, F.name);
					INC(nofFonts); F.next := First; First := F;
					list := X11.ListFonts(X11.display, SYSTEM.ADR(fileName), 1, count);
					IF (list # 0) & (count = 1) THEN
						raster.xid := X11.LoadFont(X11.display, SYSTEM.ADR(fileName));
						X11.FreeFontNames(list)
					ELSE raster.xid := 0
					END
				END
			ELSE F := Default
            END
		END;
		RETURN F
	END This;

	PROCEDURE Init;
		VAR u: LONGINT;
	BEGIN
		mapFileName := defaultMapFileName;
		Args.Get(Args.Pos("-f") + 1, mapFileName);
		Default := This("Syntax10.Scn.Fnt");
		IF Default = NIL THEN
			Console.String("Fonts.Init: default font not found: Syntax10.Scn.Fnt"); Console.Ln;
			Platform.Exit(1)
		END;
		IF mapFileName = "Big.Map" THEN Unit := 8000
		ELSIF mapFileName = "Medium.Map" THEN Unit := 9000
		ELSE Unit := 10000
		END;
		u := Unit; Args.GetInt(Args.Pos("-u") + 1, u); Unit := SHORT(u);
		Display.Unit := Unit
	END Init;

BEGIN
	First := NIL; Default := NIL; nofFonts := 0; Init
END Fonts.
