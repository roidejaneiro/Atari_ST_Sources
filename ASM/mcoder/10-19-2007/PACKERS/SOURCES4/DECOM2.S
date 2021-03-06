;
; DECOMPACTEUR HUFFMANN 8 BITS OPTIMAL ???
;
; LONGUEUR : 114 OCTETS !!!
;
LOADED=$40000		;ADRESSE DE CHARGEMENT DU CODE COMPRESSE
DEBUT=$50000		;ADRESSE DE DECOMPRESSION
FIN=DEBUT+20611		;ADRESSE DE FIN DE DECOMPRESSION
;			;INUTILE PARCE QU'UN CODE EST RESERVE
;			; POUR LA FIN DU FICHIER, MAIS NON TESTE !!!
;
; PROFONDEUR DE PILE UTILISEE :
;	NB BITS HUFFMANN MAXIMUM*8
;	+4 POUR LE PREMIER BSR
;	+(NB DE NOEUDS DE L'ARBRE+NB FEUILLES)*2
;	+QUELQUES OCTETS POUR LES INTERRUPTIONS SI MODE SUPERVISEUR
;
; SOIT A PEU PRES 31*8+4+??*2+60
;
; 2500 SEMBLE SUFFIRE AMPLEMENT
;
	LEA	-2500(A7),A4

	MOVE.L	#$80000000,D2
	MOVEQ	#0,D6

	LEA	LOADED,A2
	BSR.S	DECODE		;COLLECTE LES CODES DE HUFFMANN
				;A PARTIR DE A4
	MOVE	(A4)+,D1	;PREND LA RACINE

	LEA	DEBUT,A5
	LEA	FIN,A6
BCL:
;
; ON DECODE UN OCTET EN PARCOURANT L'ARBRE
;
	MOVE.L	A4,A0
	MOVE	D1,D0
	BMI.S	DECO2		;SI UN SEUL OCTET DANS L'ARBRE
X1:	ADD.L	D2,D2
	BNE.S	X2
	MOVE.L	(A2)+,D2
	ADDX.L	D2,D2
X2:	BCC.S	X3		;ON SAUTE OU PAS
	ADD	D0,A0		;TOUT BETEMENT...
X3:	MOVE	(A0)+,D0
	BPL.S	X1
DECO2:
;
; D0.B=OCTET DECODE !!!
;
	MOVE.B	D0,(A5)+
	CMP.L	A6,A5
	BLO.S	BCL
	ILLEGAL
;
; DECODAGE DE L'ARBRE DE HUFFMANN
;
; ROUTINE RECURSIVE
;
; UTILISE A6,A2
;
DECODE3:
	PEA	(A6)		;MARQUAGE D'UNE BRANCHE
	BSR.S	DECODE2		;A6 POINTE SUR LA FEUILLE DE DROITE
	MOVE.L	(A7)+,A6
	MOVE	A4,D0
	SUB	A6,D0		;A4-A6+D6
	ADD	D6,D0		;TOUJOURS >0 ET <32768 !!!
	MOVE	D0,(A6)		;POINTE SUR LA FEUILLE DE GAUCHE
DECODE2:
	ADDQ	#2,D6
DECODE:
	LEA	0(A4,D6.W),A6

	ADD.L	D2,D2
	BNE.S	TSTCARY2
	MOVE.L	(A2)+,D2
	ADDX.L	D2,D2
TSTCARY2:
	BCC.S	DECODE3

	MOVE	#$8001,D1	;MARQUE UN NOEUD TERMINAL
L1F2EE:	ADD.L	D2,D2
	BNE.S	TSTCARY3
	MOVE.L	(A2)+,D2
	ADDX.L	D2,D2
TSTCARY3:
	ADDX.B	D1,D1
	BCC.S	L1F2EE
	MOVE	D1,(A6)+	;ET STOCKE SA VALEUR
	RTS
;
; C'EST TRES COURT, N'EST-CE PAS ?
;
