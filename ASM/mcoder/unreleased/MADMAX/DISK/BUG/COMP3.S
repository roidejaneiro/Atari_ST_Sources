SOURCE=$40AB0
DEST=$50000
O=SOURCE

	LEA	DEST,A6

	MOVE.L	#'COSO',(A6)+
	MOVEQ	#7-1,D0
CLRC:	CLR.L	(A6)+
	DBRA	D0,CLRC

	LEA	SOURCE+32,A5
	MOVEQ	#8-1,D0
COPYC:	MOVE.L	(A5)+,(A6)+
	DBRA	D0,COPYC
;
; COPIE DES VOLUMES
;
	MOVE.L	A6,D0
	SUB.L	#DEST,D0
	MOVE.L	D0,DEST+4

	MOVE	SOURCE+$24,D7	;NB INSTRUMENTS

	BSR	COMPACTE1
;
; COPIE DES FREQUENCES
;
	MOVE.L	A6,D0
	SUB.L	#DEST,D0
	MOVE.L	D0,DEST+8

	MOVE	SOURCE+$26,D7	;NB INSTRUMENTS

	BSR	COMPACTE1
;
; COPIE DES PATTERNS
;
	MOVE.L	A6,D0
	SUB.L	#DEST,D0
	MOVE.L	D0,DEST+12

	LEA	SOURCE,A5
	ADD.L	12(A5),A5

	MOVE	SOURCE+$28,D7	;NB PATTERNS
	BSR	COMPACTE2
;
; COPIE DES ENCHAINEMENTS
;
	MOVE.L	A6,D0
	SUB.L	#DEST,D0
	MOVE.L	D0,DEST+16
	MOVE	SOURCE+$2A,D7
COPIPAT:MOVE.L	(A5)+,(A6)+
	MOVE.L	(A5)+,(A6)+
	MOVE.L	(A5)+,(A6)+
	DBRA	D7,COPIPAT
;
; COPIE DES REPERES
;
	MOVE.L	A6,D0
	SUB.L	#DEST,D0
	MOVE.L	D0,DEST+20

	MOVEQ	#8-1,D0
	MOVE.L	A6,A2
COPI3:	MOVE.L	(A5),D1
	OR	4(A5),D1
	TST.L	D1
	BEQ.S	FINI
	MOVE.L	(A5)+,(A6)+
	MOVE	(A5)+,(A6)+
	DBRA	D0,COPI3
FINI:
	LEA	DEST,A0
	MOVE.L	A6,A1

	MOVEQ	#0,D0
	ILLEGAL


COMPACTE1:
	MOVE.L	A5,A0
	MOVE.L	A6,A4
	MOVE	D7,D0
CLRFREQ:CLR	(A6)+
	ADDQ	#4,A0
	DBRA	D0,CLRFREQ

COPYFREQ:
	MOVE.L	A6,D0
	SUB.L	#DEST,D0
	MOVE	D0,(A4)+

	LEA	SOURCE,A1
	ADD.L	(A5)+,A1
	CMP.L	A0,A1
	BEQ.S	COPYFREQ2
	MOVEQ	#-1,D0
;	ILLEGAL
	MOVE.L	A1,A0

COPYFREQ2:
	MOVE.B	(A0)+,D0
	MOVE.B	D0,(A6)+
	CMP.B	#$E1,D0
	BEQ.S	FINFREQ
	CMP.B	#$E0,D0
	BNE.S	COPYFREQ2
	MOVE.B	(A0)+,(A6)+
FINFREQ:
	DBRA	D7,COPYFREQ

	MOVE.L	A0,D0
	ADDQ.L	#1,D0
	AND.L	#-2,D0
	MOVE.L	D0,A5

	MOVE	A6,D0
	LSR	#1,D0
	BCC.S	PAIR2
	CLR.B	(A6)+
PAIR2:
	RTS


COMPACTE2:

	MOVE.L	A5,A0
	MOVE.L	A6,A4
	MOVE	D7,D0
CLRFR:	CLR	(A6)+
	ADDQ	#4,A0
	DBRA	D0,CLRFR

COPYFR:
	MOVE.L	A6,D0
	SUB.L	#DEST,D0
	MOVE	D0,(A4)+

	LEA	SOURCE,A1
	ADD.L	(A5)+,A1
	CMP.L	A0,A1
	BEQ.S	COPYFR2
	MOVEQ	#-1,D0
	ILLEGAL
COPYFR2:
	MOVE.B	(A0)+,D0
	MOVE.B	D0,(A6)+
	CMP.B	#$FF,D0
	BNE.S	COPYFR2

	DBRA	D7,COPYFR

	MOVE.L	A0,D0
	ADDQ.L	#1,D0
	AND.L	#-2,D0
	MOVE.L	D0,A5

	MOVE	A6,D0
	LSR	#1,D0
	BCC.S	PAIR3
	CLR.B	(A6)+
PAIR3:
	RTS
