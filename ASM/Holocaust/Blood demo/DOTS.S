;
; 5992 Dots - Code by Zappy/Holocaust
;
; On peut monter jusqu'� 5999 mais j'ai pr�f�r� laisser une mini-marge de
; s�curit�...
;
; Hey Keops, t'as vu?! Ca tient meme dans un 260 ST! huhuhu...

NB_PTS	=	7*856	(5992)

Y_DEP	=	160*8

MAIN	CLR.L	-(SP)
	MOVE.W	#$20,-(SP)
	TRAP	#1
	ADDQ.W	#6,SP

	CLR	-(SP)
	PEA	-1.W
	PEA	-1.W
	MOVE	#5,-(SP)
	TRAP	#14
	LEA	12(SP),SP

	CLR.B	$FFFFFA07.W
	CLR.B	$FFFFFA09.W
	MOVE.L	#INTER_RTE,$70.W

	MOVEQ	#1,D0
	JSR	ZIK

*************************************************************************

	MOVE.L	#FIN,$008.W
	MOVE.L	#FIN,$00C.W
	MOVE.L	#FIN,$010.W
	MOVE.L	#FIN,$014.W
	MOVE.L	#FIN,$018.W
	MOVE.L	#FIN,$01C.W
	MOVE.L	#FIN,$020.W

	LEA	DEB_BSS,A0
	LEA	END_BSS,A1
.KILL_BSS	
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CMP.L	A1,A0
	BLE.S	.KILL_BSS

	LEA	SAVE_RAM,A0
	LEA	$600.W,A1
	MOVE	#15999,D7
.SAVE_IT	MOVE.L	(A1)+,(A0)+
	DBF	D7,.SAVE_IT
	LEA	$600.W,A0
	MOVE	#15999,D7
	MOVEQ	#0,D0
.KILL_IT	MOVE.L	D0,(A0)+
	DBF	D7,.KILL_IT

	MOVE.L	#$00010001,D0
	MOVE.L	D0,$FFFF8240.W
	MOVE.L	D0,$FFFF8244.W
	MOVE.L	D0,$FFFF8248.W
	MOVE.L	D0,$FFFF824C.W
	MOVE.L	D0,$FFFF8250.W
	MOVE.L	D0,$FFFF8254.W
	MOVE.L	D0,$FFFF8258.W
	MOVE.L	D0,$FFFF825C.W

	LEA	$600.W,A0
	MOVE	A0,SCREEN1
	LEA	(200-8)*160(A0),A0
	MOVE	A0,SCREEN2

	MOVE.L	#BIG_BUF1,ADR1
	MOVE.L	#BIG_BUF2,ADR2
	MOVE.L	#BUF_COD,COD1
	MOVE.L	#BUF_COD2,COD2

	CLR.B	$FFFF8201.W
	MOVE.B	SCREEN1,$FFFF8203.W

	MOVE	SCREEN1,D0
	SWAP	D0
	CLR	D0
	SWAP	D0
	MOVE.L	D0,A0
	LEA	160*40(A0),A0
	MOVE	SCREEN2,D0
	SWAP	D0
	CLR	D0
	SWAP	D0
	MOVE.L	D0,A1
	LEA	160*40(A1),A1
	LEA	TXT,A2
	MOVE	#24-1,D7
.AF_TXT
N	SET	0
	REPT	20
	MOVE	(A2),N+2(A0)
	MOVE	(A2)+,N+2(A1)
N	SET	N+8
	ENDR
	LEA	160(A0),A0
	LEA	160(A1),A1
	DBF	D7,.AF_TXT
	MOVE	#$666,$FFFF8244.W

	MOVE.L	#VBL_DEB,$70.W

	LEA	XS,A0
	LEA	16000(A0),A1
	MOVE	#3999,D7
.COPXS	MOVE.L	(A0)+,(A1)+
	DBF	D7,.COPXS

	JSR	PREP_MOUNT
	JSR	COD_GEN

	MOVE.L	#INTER_RTE,$120.W
	MOVE.L	#INTER_RTE,$134.W

	MOVE.L	#VBL_DOTS,$70.W

BOUCLE	BRA.S	BOUCLE
FAD_DEB	DC	$001,$112,$223,$334,$445,$556,$667,$1234
POF	DC	3
VBL_DEB	MOVEM.L	D0-A6,-(SP)
	LEA	FAD_DEB,A0
MODF	EQU	*+2
	LEA	0(A0),A0
	CMPI	#$1234,2(A0)
	BEQ.S	.OK
	SUBQ	#1,POF
	BNE.S	.OK
	MOVE	#3,POF
	ADDQ	#2,MODF
.OK	MOVE	(A0),$FFFF8244.W
	JSR	RT_ZIK
	MOVEM.L	(SP)+,D0-A6
	RTE
VBL_DOTS
	MOVE	#$001,$FFFF8240.W
	MOVE	#$444,$FFFF8242.W
	MOVE	#$444,$FFFF8246.W
	MOVE	#$444,$FFFF8250.W
	MOVE	#$444,$FFFF8256.W

	JSR	EFFACE

	MOVE.L	COD1,MODCOD
	MOVE.L	ADR1,A0
MOD_DEP	EQU	*+2
	ADDA.L	#0,A0
	LEA	POPO,A1
	MOVEM	(A1),D0-D7
MODCOD	EQU	*+2
	JSR	$12345678

	JSR	SWAPEC

	ADDQ.L	#4,MOD_DEP
	CMPI.L	#16000,MOD_DEP
	BNE.S	.AZ
	CLR.L	MOD_DEP
.AZ
	CMPI.B	#$39,$FFFFFC02.W
	BEQ.S	FIN
	
	JSR	RT_ZIK
	ADDQ	#1,TIME
	RTE
TIME	DC	0
RT_ZIK	JSR	ZIK+4
	RTS
FIN	
	LEA	SAVE_RAM,A1
	LEA	$600.W,A0
	MOVE	#15999,D7
.SAVE_IT	MOVE.L	(A1)+,(A0)+
	DBF	D7,.SAVE_IT

	MOVE.L	4.W,A0
	JMP	(A0)

INTER_RTE	RTE

POPO
	DC	%10000000
	DC	%1000000
	DC	%100000
	DC	%10000
	DC	%1000
	DC	%100
	DC	%10
	DC	%1

SWAPEC	MOVE	SCREEN1,D0
	MOVE	SCREEN2,SCREEN1
	MOVE	D0,SCREEN2

	MOVE.L	ADR1,D0
	MOVE.L	ADR2,ADR1
	MOVE.L	D0,ADR2

	MOVE.L	COD1,D0
	MOVE.L	COD2,COD1
	MOVE.L	D0,COD2

	;MOVE.B	SCREEN1+1,$FFFF8201.W
	;MOVE.B	SCREEN1+2,$FFFF8203.W

	CLR.B	$FFFF8201.W
	MOVE.B	SCREEN2,$FFFF8203.W
	RTS

EFFACE
	MOVE	SCREEN1,D0
	SWAP	D0
	CLR	D0
	SWAP	D0
	MOVE.L	D0,A0
	ADDA	#Y_DEP,A0
N	SET	5
	LEA	160*(25+N)(A0),A0

	MOVEQ	#0,D0
	MOVE	#(200-8*2-40-N+2)-1,D7
.EFF
N	SET	0
	REPT	10
	MOVE.L	D0,N+6(A0)
N	SET	N+16
	ENDR
	LEA	160(A0),A0
	DBF	D7,.EFF
	RTS

COD_GEN	LEA	CORES_X2,A2
	LEA	BUF_COD,A3
	LEA	BUF_COD2,A4
	MOVE	#$4E67,(A3)+
	MOVE	#$4E67,(A4)+
	LEA	TABL_PLANS,A5
	LEA	XS,A6
	;LEA	WAVE,A6

	;MOVE	#0,V_X

	MOVE.W	#(NB_PTS/7)-1,D7
.AFF_SIX
	MOVE.L	#$4C98FE00,(A3)+
	MOVE.L	#$4C98FE00,(A4)+
	MOVE	#$29,D5
	MOVEQ	#7-1,D6
.LP
	;MOVE	V_X,D0
	;ADDQ	#1,V_X
	MOVE	#200,D1
	MOVE	#100,D2

;	CMPI	#320,V_X
;	BNE.S	.NO_CLIP
;	MOVE	#0,V_X
;.NO_CLIP

	MOVE	(A6)+,D0
	;EXT.L	D0
	;DIVS	#160,D0
	;ADD	D0,D0
	ADD	#160,D0

	TST	D0
	BGE.S	.OK
	CLR	D0
.OK	CMPI	#320,D0
	BLT.S	.OK2
	MOVE	#319,D0
.OK2

	MULS.W	#160,D1
	MULS.W	#160,D2
	ADD.W	D0,D0
	ADD.W	D0,D0
	ADD.W	2(A2,D0.W),D1
	ADD.W	2(A2,D0.W),D2
	
	ADD	(A5,D0.W),D1
	ADD	(A5,D0.W),D2
	
	MOVE.W	(A2,D0.W),D0

	MOVE	D5,(A3)
	MOVE.B	D0,(A3)
	MOVE	D2,2(A3)
	ADDQ	#4,A3

	MOVE	D5,(A4)
	MOVE.B	D0,(A4)
	MOVE	D1,2(A4)
	ADDQ	#4,A4

.NO
	ADDQ	#1,D5
	DBF	D6,.LP

	DBRA	D7,.AFF_SIX
	MOVE	#$4E6F,(A3)+
	MOVE	#$4E6F,(A4)+
	MOVE	#$4E75,(A3)
	MOVE	#$4E75,(A4)
	RTS
;V_X	DC	0

PREP_MOUNT	;LEA	WAVE,A0
	LEA	XS,A0
	LEA	BIG_BUF1,A1
	LEA	BIG_BUF2,A2
	MOVE	SCREEN1,D0
	MOVE	SCREEN2,D1
	ADD	#Y_DEP,D0
	ADD	#Y_DEP,D1

	MOVE	#15999,D7
.DO_TRANSFO	MOVEQ	#0,D6
	MOVE	(A0)+,D6
	EXT.L	D6
	LSL.L	#8,D6
	DIVS	#585,D6
	MULS	#160,D6

	;SUB	#200*160,D6
	;ADD	#160*180,D6
	;;LEA	-200*160+160*180(A0),A0
	;;LSR	#1,D6

	MOVE	D0,(A1)
	ADD	D6,(A1)+
	MOVE	D1,(A2)
	;LEA	-160*80-160*100(A0),A0
	SUB	#100*160,D6
	ADD	D6,(A2)+
	
	DBF	D7,.DO_TRANSFO
	RTS

	DCB.W	500,0
N	SET	0
CORES_X2	REPT	20
	DC	$81,N
	DC	$83,N
	DC	$85,N
	DC	$87,N
	DC	$89,N
	DC	$8B,N
	DC	$8D,N
	DC	$8F,N
	DC	$81,N+1
	DC	$83,N+1
	DC	$85,N+1
	DC	$87,N+1
	DC	$89,N+1
	DC	$8B,N+1
	DC	$8D,N+1
	DC	$8F,N+1
N	SET	N+8
	ENDR
	DCB.W	500,0

TABL_PLANS
	REPT	10
	DCB	32,6
	DCB	32,0
	ENDR

TXT	INCBIN	LEO.TXT

ZIK	INCBIN	BUGGIN10.MUS
XS	INCBIN	XS.DAT
XS_END	DS.B	16000
	BSS
;BSS g�n�rale
DEB_BSS
SAVE_RAM	DS.B	64000
SCREEN1	DS.W	1
SCREEN2	DS.W	1
ADR1	DS.L	1
ADR2	DS.L	1
COD1	DS.L	1
COD2	DS.L	1
BUF_COD	DS.B	30000
BUF_COD2	DS.B	30000
BIG_BUF1	DS.B	32000
BIG_BUF2	DS.B	32000
END_BSS