	MOVE.L	#$BB9B-1,D7

;	LEA	$19C8A+8+$BB9B,A2
	LEA	$2582D,A2

;	LEA	$19C8A+8+$BB9B+$373D9,A1
	LEA	$5CC06,A1

;	LEA	$BB9B*8+$19C8A,A0
	LEA	$77962,A0
	LEA	$70000,A3

	CLR.B	D6
L233D8:	MOVE.B	-(A2),D0
	BTST	#7,D0
	BEQ	L23430
	MOVE.B	-(A1),-(A0)
	BTST	#6,D0
	BEQ	L2343A
L233EC:	MOVE.B	-(A1),-(A0)
	BTST	#5,D0
	BEQ	L23444
L233F6:	MOVE.B	-(A1),-(A0)
	BTST	#4,D0
	BEQ	L2344E
L23400:	MOVE.B	-(A1),-(A0)
	BTST	#3,D0
	BEQ	L23458
L2340A:	MOVE.B	-(A1),-(A0)
	BTST	#2,D0
	BEQ	L23462
L23414:	MOVE.B	-(A1),-(A0)
	BTST	#1,D0
	BEQ	L2346C
L2341E:	MOVE.B	-(A1),-(A0)
	BTST	#0,D0
	BEQ	L23476
L23428:	MOVE.B	-(A1),-(A0)
	CMP.L	A3,A0
	BLO	FINI
	DBF	D7,L233D8
	BRA	FINI
L23430:	MOVE.B	D6,-(A0)
	BTST	#6,D0
	BNE	L233EC
L2343A:	MOVE.B	D6,-(A0)
	BTST	#5,D0
	BNE	L233F6
L23444:	MOVE.B	D6,-(A0)
	BTST	#4,D0
	BNE	L23400
L2344E:	MOVE.B	D6,-(A0)
	BTST	#3,D0
	BNE	L2340A
L23458:	MOVE.B	D6,-(A0)
	BTST	#2,D0
	BNE	L23414
L23462:	MOVE.B	D6,-(A0)
	BTST	#1,D0
	BNE	L2341E
L2346C:	MOVE.B	D6,-(A0)
	BTST	#0,D0
	BNE	L23428
L23476:	MOVE.B	D6,-(A0)
	CMP.L	A3,A0
	BLO	FINI
	DBF	D7,L233D8
FINI:
	ILLEGAL

