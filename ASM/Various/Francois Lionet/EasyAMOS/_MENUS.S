
;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* MENUS
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------
* D0-> Majuscule
D0Maj:	cmp.b	#"a",d0
	bcs.s	.skip
	cmp.b	#"z",d0
	bhi.s	.skip
	sub.b	#32,d0
.skip	rts
