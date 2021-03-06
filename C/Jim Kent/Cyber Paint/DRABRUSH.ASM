
; :ts=10

	cseg
	public _putdot

	dseg
	public _zoom_flag
	public _cscreen
	public _preshift1
	public _preshift2
	public _black
	public _white
	public _mouse_x
	public _mouse_y
	public _brush_ix
	public _use_cursor0
	public _oppositec
	public _bitmasks

	; This file contains some interesting routines and a bunch of
	; boring ones.  The purpose of them all is to very quickly draw
	; a 16x16 brush onto the screen.  To avoid branches in the
	; inner loop based on color, I've resorted to the ever popular
	; on the ST expedient of coding one routine for each color.
	; Thus this file looks very big but it actually contains very
	; little.

	; Also for speeds sake I have 16 copies of the active brush.
	; Each is shifted a pixel right of the one before.
	; The lower 4 bits of the x drawing position determine which
	; copy of the brush is used, and I don't shift at all during 
	; draw time, just when the "current" brush is changed.


	cseg


	; shift_brush - make shifted copy of brush .. ie 16x16x1 bitmap
	;	a0 = brush
	;	a1 = place to put shifted copy
	;	d0 = #to shift
shift_brush 
	move.l	#15,d2
scurloop	 move.w	(a0)+,d1
	swap	d1
	move.w	#0,d1
	lsr.l	d0,d1
	move.l	d1,(a1)+
	dbra	d2,scurloop
	rts

	;preshift(brush, shifts)
	;	put 16 variously shifted copies of brush in preshifts
	;	buffer so don't have to shift during draw time...
	public _preshift
_preshift	move.l	8(sp),a1	; get destination for shifting
	move.w	#0,d0	    	; count up to 16 in d0
psloop	move.l	4(sp),a0
	bsr	shift_brush
	addq.w	#1,d0
	cmp.w	#16,d0
	bne	psloop
	rts

	;getdot(x, y)
	;	return color in cscreen at x,y
	public _getdot
	public getdot
_getdot	move.w	4(sp),d0
	move.w	6(sp),d1
getdot	move.l	_cscreen,a0 
	lsl.w	#5,d1
	adda.w	d1,a0
	add.w	d1,d1
	add.w	d1,d1
	adda.w	d1,a0	;effectively multiply y coordinate by 160 = 128+32
	move.w	d0,d1	;copy of x coordinate in d1
	and.w	#$fff0,d1	
	lsr.w	#1,d1
	adda	d1,a0	; point a0 to the right word even ... 
	move.l	#_bitmasks,a1
	and.w	#$000f,d0	; find place in word
	add.w	d0,d0	;convert to word index
	move.w	0(a1,d0.w),d1	;  now have mask in d1
	clr.w	d0	; start out color 0
	move.w	(a0)+,d2
	and.w	d1,d2
	beq	not1
	or.w	#1,d0
not1	move.w	(a0)+,d2
	and.w	d1,d2
	beq	not2
	or.w	#2,d0
not2	move.w	(a0)+,d2
	and.w	d1,d2
	beq	not4
	or.w	#4,d0
not4	move.w	(a0)+,d2
	and.w	d1,d2
	beq	not8
	or.w	#8,d0
not8	rts

	;draw_m()	
	;	draw some brushes over mouse position.
	public	_draw_m
_draw_m
	tst.w	_use_cursor0
	bne	_draw_shifted2
draw_brus 
	subq	#2,sp	; make space for color parameter
	;first do a getdot ... 
	move.w	_mouse_y,d1
	move.w	d1,-(sp)  ; put mouse_y parameter on stack
	move.w	_mouse_x,d0
	move.w	d0,-(sp)  ; put mouse_x parameter on stack
	bsr	getdot
	move.l	#_oppositec,a0
	move.b	0(a0,d0),d0	; look up opposite color
	move.w	d0,4(sp)	;color to draw in on stack frame
	subq.w	#8,2(sp)	; adjust for hotspot
	subq.w	#8,(sp)	; adjust for hotspot
	jsr	_draw_shifted
	addq	#6,sp
	rts

	; draw_brush0 -
	;	if zooming draw a single opposite-colored dot for cursor,
	;	otherwise draw "hollow cross" in black and white
	;public	_draw_brush0
;_draw_brush0
	;tst.w	_zoom_flag
	;beq	_draw_shifted2
	;subq.w	#2,sp		; space for color parameter
	;move.w	_mouse_y,d1
	;move.w	d1,-(sp)  ; put mouse_y parameter on stack
	;move.w	_mouse_x,d0
	;move.w	d0,-(sp)  ; put mouse_x parameter on stack
	;bsr	getdot
	;move.l	#_oppositec,a0
	;move.b	0(a0,d0),d0	; look up opposite color
	;move.w	d0,4(sp)	;color to draw in on stack frame
	;jsr	_putdot
	;addq	#6,sp
	;rts


	;cdraw_brush(brush, x, y, color)
	;	draw brush, but adjust for hot-spot first
	public _cdraw_brush
_cdraw_brush
	subq.w	#8,8(sp)
	subq.w	#8,10(sp)

	;draw_brush(brush, x, y, color)
		; draw unpre-shifted brush
	public _draw_brush
_draw_brush
	;	first go make an alligned copy of brush int shift_buf
	move.l	4(sp),a0
	move.w	8(sp),d0
	and.w	#15,d0
	move.l	#shift_buf,a1
	bsr	shift_brush
	;	now have to re-arrange stack parameters, what a drag!
	move.l	8(sp),4(sp)	; move over x and y
	move.w	12(sp),8(sp)	; move over color
	move.l	#shift_buf,a2
	bra	draw_alligned_brush

	;draw_shifted2()
		; draw 2 brushes from 2 pre-shifted arrays
		; one in white the other in black
	public _draw_shifted2
_draw_shifted2
	subq	#6,sp
	move.w	_mouse_y,d0
	subq.w	#8,d0
	move.w	d0,2(sp)
	move.w	_white,4(sp)
	move.w	_mouse_x,d0
	subq.w	#8,d0
	move.w	d0,(sp)
	move.l	#_preshift1,a2	;get address of preshifts
	and.w	#15,d0
	lsl.w	#6,d0
	adda.w	d0,a2		; and add x%15 * sizeof(preshift)
	bsr	draw_alligned_brush
	move.w	_black,4(sp)
	move.l	#_preshift2,a2	;get address of preshifts
	move.w	(sp),d0
	and.w	#15,d0
	lsl.w	#6,d0
	adda.w	d0,a2
	bsr	draw_alligned_brush
	addq	#6,sp
	rts


	;draw_shifted(x, y, color)
		; draw brush from pre-shifted array
		; only drag is that for draw_alligned_brush
		; rearranging stack frame ...
	public _draw_shifted
_draw_shifted
	move.l	#_preshift1,a2	;get address of preshifts
	move.w	4(sp),d0	;get x coordinate
	and.w	#15,d0	;only interested in last 4 bits
	lsl.w	#6,d0	;64 bytes/preshifted copy
	adda.w	d0,a2	;now a0 points to brush properly shifted for x
	;	and fall through to draw_alligned_brush



	;draw_alligned_brush(x, y, color)
		; draw pre-shifted brush
		; x,y,color arguments on stack,
		; brush pointer already in a2
draw_alligned_brush
	move.w	#15,d1	;line count
get_y
	move.w	6(sp),d0	; get y coordinate
	bge	yposi	; start clipping ... at least it's positive
	cmp.w	#-16,d0	; is it completely above screen?
	bls	clipout
	add.w	d0,d1	; y negative a little, makes less than 16 lines...
	move.w	d0,d2
	add.w	d2,d2
	add.w	d2,d2
	suba.w	d2,a2	; and we have to start in middle of source
	move.w	#0,d0	; and after clipping start at 0
	bra	get_color	; and go get y address
yposi
	cmp.w	#200,d0	; totally below screen?
	bge	clipout
	move.w	d0,d2
	sub.w	#200-16,d2  ; # of lines off bottom of screen in d2
	bls	get_color	; if negative or zero don't have to clip
	sub.w	d2,d1	; ready to draw a few less lines
get_color	
	move.w	8(sp),d2	; get color parameter
	add.w	d2,d2	; convert to pointer value 
	add.w	d2,d2	; convert to pointer value 
get_x
	move.l	_cscreen,a0
	lsl.w	#5,d0
	adda.w	d0,a0
	add.w	d0,d0
	add.w	d0,d0
	adda.w	d0,a0	; add 160*y to cscreen and put in a0
	move.w	4(sp),d0	; get x coordinate
	bge	xposi	; x is positive at least
	cmp.w	#-16,d0	; if negative is it offscreen entirely?
	bls	clipout	
	bra 	left_edge 
xposi
	cmp.w	#320,d0	; is it offscreen to right?
	bge	clipout
	cmp.w	#320-16,d0 ; partially right clipped?
	bls	add_xadd
	bra	right_edge	
add_xadd
	and.w	#$fff0,d0	
	lsr.w	#1,d0
	adda.w	d0,a0	; point a0 to the right word even ... 
	move.l	#ds_cs,a1
	move.l	0(a1,d2.w),a1	; get rest of routine for this color
	jmp	(a1)
clipout	rts


left_edge	 adda.w	#2,a2	; skip left part of brush
	bra do_edge
right_edge  
	adda.w	#160-8,a0 ; we're in the last word of this line
do_edge
	move.l	#ss_cs,a1
	move.l	0(a1,d2.w),a1	; get clipped routine for this color
	jmp	(a1)


;	start of repetitive code, bunch of routines, one for each color.
;	dsc? moves a full brush to screen,  ssc? moves either left or
;	right half of brush to screen (seems useless but it happens when
;	you're on the edge ... another complexity added by clipping
;
dsc0:	
	move.w	(a2)+,d0
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	move.w	(a2)+,d0
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	adda	#160-16,a0	; go to next row of dest
	dbra	d1,dsc0
	rts

dsc1: 
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	adda	#160-16,a0	; go to next row of dest
	dbra	d1,dsc1
	rts

dsc2: 
	move.w	(a2)+,d0
	or.w	d0,2(a0)
	not.w	d0
	and.w	d0,0(a0)
	and.w	d0,4(a0)
	and.w	d0,6(a0)
	move.w	(a2)+,d0
	or.w	d0,8+2(a0)
	not.w	d0
	and.w	d0,8+0(a0)
	and.w	d0,8+4(a0)
	and.w	d0,8+6(a0)
	adda.w	#160,a0	; go to next row of dest
	dbra	d1,dsc2
	rts

dsc3:
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	adda.w	#160-16,a0	; go to next row of dest
	dbra	d1,dsc3
	rts

dsc4:
	move.w	(a2)+,d0
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)
	adda.w	#4,a0
	and.w	d0,(a0)+
	move.w	(a2)+,d0
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)
	addq	#4,a0
	and.w	d0,(a0)+
	adda.w	#160-16,a0	; go to next row of dest
	dbra	d1,dsc4
	rts

dsc5:
	move.w	(a2)+,d0
	or.w	d0,0(a0)
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,2(a0)
	and.w	d0,6(a0)
	move.w	(a2)+,d0
	or.w	d0,8+0(a0)
	or.w	d0,8+4(a0)
	not.w	d0
	and.w	d0,8+2(a0)
	and.w	d0,8+6(a0)
	adda.w	#160,a0	; go to next row of dest
	dbra	d1,dsc5
	rts

dsc6:
	move.w	(a2)+,d0
	or.w	d0,2(a0)
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,0(a0)
	and.w	d0,6(a0)
	move.w	(a2)+,d0
	or.w	d0,8+2(a0)
	or.w	d0,8+4(a0)
	not.w	d0
	and.w	d0,8+0(a0)
	and.w	d0,8+6(a0)
	adda.w	#160,a0	; go to next row of dest
	dbra	d1,dsc6
	rts

dsc7:
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	adda.w	#160-16,a0	; go to next row of dest
	dbra	d1,dsc7
	rts

dsc8:	
	move.w	(a2)+,d0
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	not.w	d0
	or.w	d0,(a0)+
	move.w	(a2)+,d0
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	not.w	d0
	or.w	d0,(a0)+
	adda.w	#160-16,a0	; go to next row of dest
	dbra	d1,dsc8
	rts

dsc9: 
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)
	adda.w	#4,a0
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)
	adda.w	#160+4-16,a0	; go to next row of dest
	dbra	d1,dsc9
	rts

dsca: 
	move.w	(a2)+,d0
	or.w	d0,2(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,0(a0)
	and.w	d0,4(a0)
	move.w	(a2)+,d0
	or.w	d0,8+2(a0)
	or.w	d0,8+6(a0)
	not.w	d0
	and.w	d0,8+0(a0)
	and.w	d0,8+4(a0)
	adda.w	#160,a0	; go to next row of dest
	dbra	d1,dsca
	rts

dscb:
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,2(a0)
	not.w	d0
	and.w	d0,(a0)
	adda.w	#4,a0
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,2(a0)
	not.w	d0
	and.w	d0,(a0)
	adda.w	#160-16+4,a0	; go to next row of dest
	dbra	d1,dscb
	rts

dscc:
	move.w	(a2)+,d0
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	not.w	d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	move.w	(a2)+,d0
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	not.w	d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	adda.w	#160-16,a0	; go to next row of dest
	dbra	d1,dscc
	rts

dscd:
	move.w	(a2)+,d0
	or.w	d0,0(a0)
	or.w	d0,4(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,2(a0)
	move.w	(a2)+,d0
	or.w	d0,8+0(a0)
	or.w	d0,8+4(a0)
	or.w	d0,8+6(a0)
	not.w	d0
	and.w	d0,8+2(a0)
	adda.w	#160,a0	; go to next row of dest
	dbra	d1,dscd
	rts

dsce:
	move.w	(a2)+,d0
	or.w	d0,2(a0)
	or.w	d0,4(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,0(a0)
	move.w	(a2)+,d0
	or.w	d0,8+2(a0)
	or.w	d0,8+4(a0)
	or.w	d0,8+6(a0)
	not.w	d0
	and.w	d0,8+0(a0)
	adda.w	#160,a0	; go to next row of dest
	dbra	d1,dsce
	rts

dscf:
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	move.w	(a2)+,d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	adda.w	#160-16,a0	; go to next row of dest
	dbra	d1,dscf
	rts

ssc0:	
	move.w	(a2),d0
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	adda	#160-8,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssc0
	rts

ssc1: 
	move.w	(a2),d0
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	adda	#160-8,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssc1
	rts

ssc2: 
	move.w	(a2),d0
	or.w	d0,2(a0)
	not.w	d0
	and.w	d0,0(a0)
	and.w	d0,4(a0)
	and.w	d0,6(a0)
	adda.w	#160,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssc2
	rts

ssc3:
	move.w	(a2),d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	adda.w	#160-8,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssc3
	rts

ssc4:
	move.w	(a2),d0
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)
	adda.w	#4,a0
	and.w	d0,(a0)+
	adda.w	#160-8,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssc4
	rts

ssc5:
	move.w	(a2),d0
	or.w	d0,0(a0)
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,2(a0)
	and.w	d0,6(a0)
	adda.w	#160,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssc5
	rts

ssc6:
	move.w	(a2),d0
	or.w	d0,2(a0)
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,0(a0)
	and.w	d0,6(a0)
	adda.w	#160,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssc6
	rts

ssc7:
	move.w	(a2),d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	not.w	d0
	and.w	d0,(a0)+
	adda.w	#160-8,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssc7
	rts

ssc8:	
	move.w	(a2),d0
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	not.w	d0
	or.w	d0,(a0)+
	adda.w	#160-8,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssc8
	rts

ssc9: 
	move.w	(a2),d0
	or.w	d0,(a0)+
	or.w	d0,4(a0)
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)
	adda.w	#160+4-8,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssc9
	rts

ssca: 
	move.w	(a2),d0
	or.w	d0,2(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,0(a0)
	and.w	d0,4(a0)
	adda.w	#160,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssca
	rts

sscb:
	move.w	(a2),d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,2(a0)
	not.w	d0
	and.w	d0,(a0)
	adda.w	#160-8+4,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,sscb
	rts

sscc:
	move.w	(a2),d0
	not.w	d0
	and.w	d0,(a0)+
	and.w	d0,(a0)+
	not.w	d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	adda.w	#160-8,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,sscc
	rts

sscd:
	move.w	(a2),d0
	or.w	d0,0(a0)
	or.w	d0,4(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,2(a0)
	adda.w	#160,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,sscd
	rts

ssce:
	move.w	(a2),d0
	or.w	d0,2(a0)
	or.w	d0,4(a0)
	or.w	d0,6(a0)
	not.w	d0
	and.w	d0,0(a0)
	adda.w	#160,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,ssce
	rts

sscf:
	move.w	(a2),d0
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	or.w	d0,(a0)+
	adda.w	#160-8,a0	; go to next row of dest
	adda	#4,a2
	dbra	d1,sscf
	rts


	bss	shift_buf,64	; place to shift one brush

	dseg
ds_cs	dc.l 	dsc0,dsc1,dsc2,dsc3,dsc4,dsc5,dsc6,dsc7
	dc.l	dsc8,dsc9,dsca,dscb,dscc,dscd,dsce,dscf
ss_cs	dc.l 	ssc0,ssc1,ssc2,ssc3,ssc4,ssc5,ssc6,ssc7
	dc.l	ssc8,ssc9,ssca,sscb,sscc,sscd,ssce,sscf

