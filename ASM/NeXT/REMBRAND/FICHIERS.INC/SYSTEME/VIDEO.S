; REMBRANDT 3.0 - �  Dbug II
;
; Module de gestion des r�solution Falcon. (1.2)
; - Impl�mentation du scrolling Hard. (D�brayable)
; - Mode VGA g�r�
; - Toutes les r�solutions syst�me accept�e (dont Overscan)
;
; Remarques importantes:
; - La fonction XBIOS(5) effectue tous les tests qu'il faut avant
; d'accepter une r�solution, tandis que XBIOS(88) ne le fait pas.
; En pratique, on peut donc obtenir 400(480) lignes en RVB comme en VGA
; en utilisant XBIOS(5), avec le meme mot de code si l'on ne pr�cise pas
; que l'on veut du VGA. Si l'on pr�cise que c'est du VGA, on doit inverser
; le bit �double hauteur�... Pas cool !
;
 ifeq _main_part
 <pREMB_xxx.S>q doit �tre assembl� !!!
 END
 endc

 TEXT

trap_88=0
 
col2=0
col4=1
col16=2
col256=3
coltc=4

l40=0
l80=8

tv=0
vga=16
pal=32
overscan=64
st=128
interlace=256


;
; Ces 3 routines permettent de changer la r�solution de l'image directement
; depuis la page de travail (On ne sera pas oblig� de revenir sous GEM).
;
commute_largeur_�cran
 tst.s flag_vga
 bne.s .pas_avec_vga
 not.b flag_double_largeur
 bsr recopie_�cran
 bsr effectue_changement_contexte
.pas_avec_vga
 rts
 
commute_hauteur_�cran
 not.b flag_double_hauteur
 bsr recopie_�cran
 bsr effectue_changement_contexte
 rts
 
commute_overscan_�cran
 tst.s flag_vga
 bne.s .pas_avec_vga
 not.b flag_overscan
 bsr recopie_�cran
 bsr effectue_changement_contexte
.pas_avec_vga
 rts


effectue_changement_contexte
 bsr cache_zoomer_s�lecteur
 bsr cache_curseur
 bsr restaure_interruptions

 bsr valide_param�trages

 lea �cran,a0
 move.l taille_�cran,d0
 bsr realloc

 
 bsr commute_r�solution

 bsr installe_souris_absolu

 bsr installe_interruptions
 bsr teste_hbl_hard
 bsr affiche_image		Affiche l'image � l'�cran
 bsr initialise_zoomer
 bsr montre_curseur
 bsr montre_zoomer_s�lecteur
 rts






calcule_r�solution_sp�ciale
 bsr calcule_dimensions
 move dim_largeur_�cran,largeur_�cran
 move dim_hauteur_�cran,hauteur_�cran
 move dim_largeur_visible,largeur_visible
 move dim_hauteur_visible,hauteur_visible
 move.l dim_taille_�cran,taille_�cran
 move dim_mode_r�solution,mode_r�solution
 move dim_linewidth,linewidth

 bsr calcule_clipping
 clr x_scroll
 clr y_scroll
 rts
 

; A partir des dimensions de l'image, et des indications concernant le mode
; d'affichage, cette fonction calcule les dimensions de l'�cran (totale/visible),
; la taille de l'�cran, ainsi que le mot de code pour la fonction Xbios(5).
; Les r�sultats sont stock�s dans des variables portant le pr�fixe DIM_
;
calcule_dimensions
 movem.l d0/d1,-(sp)
  
 moveq #4,d0			On est en mode TrueColor 16 bits...	

 tst.b flag_vga			En VGA, le mode 80 colonnes n'est pas
 bne.s .valide_simple_colonnes	accessible...

 tst.b flag_double_largeur	On est en 40 ou en 80 colonnes ???
 beq.s .valide_simple_colonnes	(Broadcast uniquement...)
.valide_double_colonnes
 addq #8,d0			Mode 80 colonnes
 move #1280,dim_largeur_�cran
 bra.s .teste_double_ligne
.valide_simple_colonnes  
 move #640,dim_largeur_�cran

.teste_double_ligne
 tst.b flag_double_hauteur
 beq.s .valide_simple_ligne
.valide_double_ligne
 add #256,d0 
 move #400,dim_hauteur_�cran
 bra.s .teste_overscan
.valide_simple_ligne
 move #200,dim_hauteur_�cran

.teste_overscan 
 tst.b flag_vga
 bne.s .valide_normal
 tst.b flag_overscan
 beq.s .valide_normal
.valide_overscan
 add #64,d0
 move dim_largeur_�cran,d1
 mulu #12,d1
 divu #10,d1
 move d1,dim_largeur_�cran 
 move dim_hauteur_�cran,d1
 mulu #12,d1
 divu #10,d1
 move d1,dim_hauteur_�cran 
 bra.s .m�morise_r�solution
.valide_normal

.m�morise_r�solution
 tst.b flag_vga			En mode VGA, par contre, on peut
 beq.s .pas_vertical_�tendu	multiplier par 1,2 la r�solution
 move dim_hauteur_�cran,d1	verticale ! [Mwaii... Bof)
 mulu #12,d1
 divu #10,d1
 move d1,dim_hauteur_�cran 
 add #16,d0			Mode VGA
 bchg #8,d0			En VGA, le bit �double hauteur a une autre signification !�
.pas_vertical_�tendu

 add #32,d0			Mode PAL (50hz)
 
 move d0,dim_mode_r�solution

 clr dim_linewidth
 
 move dim_largeur_�cran,dim_largeur_visible
 move dim_hauteur_�cran,dim_hauteur_visible

 move largeur_image,d0
 cmp dim_largeur_�cran,d0
 ble.s .ok_largeur
 sub dim_largeur_�cran,d0		Diff�rence en octets
 lsr d0					Diff�rence en mots (???)
 btst #0,d0
 beq.s .largeur_paire
 addq #1,d0				On prend le pair sup�rieur
 move d0,dim_linewidth
 move largeur_image,dim_largeur_�cran	Puis rajoute un pixel sur 
 addq #2,dim_largeur_�cran			l'�cran.
 bra.s .ok_largeur
.largeur_paire
 move d0,dim_linewidth
 move largeur_image,dim_largeur_�cran
.ok_largeur

 move hauteur_image,d0
 cmp dim_hauteur_�cran,d0
 ble.s .ok_hauteur
 move hauteur_image,dim_hauteur_�cran
.ok_hauteur
 
 move dim_largeur_�cran,d0
 mulu dim_hauteur_�cran,d0
 move.l d0,dim_taille_�cran

 movem.l (sp)+,d0/d1
 rts

*
* Tous les d�placement de blocs ou de ressources doivent se faire dans
* un cadre qui repr�sente la plus petite taille en X et en Y de l'�cran
* et de l'image (C'est'y assez clair ???)
*
calcule_clipping
 move largeur_image,d0
 move largeur_�cran,d1
 cmp d0,d1
 bgt .pas_�change_x
 exg d0,d1
.pas_�change_x
 move d0,largeur_maximum

 move hauteur_image,d0
 move hauteur_�cran,d1
 cmp d0,d1
 bgt .pas_�change_y
 exg d0,d1
.pas_�change_y
 move d0,hauteur_maximum
 rts


 
 

commute_r�solution  
 bsr vsync
 clr x_scroll
 clr y_scroll
 ifeq trap_88
   move mode_r�solution,-(sp)	Change la r�solution comme on le veut...
   move #3,-(sp)
   move.l �cran,-(sp)
   move.l �cran,-(sp)
   move #5,-(sp)
   trap #14
   lea 14(sp),sp
 elseif
   move mode_r�solution,-(sp)	Change la r�solution comme on le veut...
   move #88,-(sp)
   trap #14
   addq #4,sp
   move.l �cran,d0
   move d0,d1
   lsr.l #8,d0
   move.b d0,$ffff8203.w
   lsr #8,d0
   move.b d0,$ffff8201.w
   move.b d1,$ffff820d.w 
 endc
 move $ffff82c2.w,sauve_vco
 move linewidth,$ffff820e.w
 
 clr.l $ffff9800.w		Met le cadre en noir
 lea �cran,a0
 bsr efface_bloc
 rts


 
teste_moniteur 
 move #89,-(sp)		C'est utile de savoir si on est en VGA, ou en
 trap #14		mode BROADCAST !!! (Ou en monochrome !)
 addq #2,sp
 move d0,type_moniteur

 sf flag_vga
 cmp #2,d0
 bne .pas_vga
 bsr ex�cute_sp�cifique_vga
.pas_vga
  
 move #objet_type_moniteur*24,d1	Offset sur la structure
 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire
 lea choix_moniteur,a1
 move.l (a1,d0.w*4),([ob_spec,a0,d1.w])	Change le ptr de texte !
 rts


ex�cute_sp�cifique_vga
 st flag_vga

 move #objet_txt_overscan*24,d1		Offset sur la structure
 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire
 bset.b #state_disabled,ob_state+1(a0,d1.w)

 move #objet_txt_dbl_largeur*24,d1	Offset sur la structure
 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire
 bset.b #state_disabled,ob_state+1(a0,d1.w)

 move #objet_overscan*24,d1		Offset sur la structure
 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire
 bset.b #state_disabled,ob_state+1(a0,d1.w)
 bclr.b #flag_selectable,ob_flags+1(a0,d1.w)

 move #objet_double_largeur*24,d1	Offset sur la structure
 move.l ptr_parametre_ecran,a0		Pointeur sur le formulaire
 bset.b #state_disabled,ob_state+1(a0,d1.w)
 bclr.b #flag_selectable,ob_flags+1(a0,d1.w)
 rts


g�re_scrolling
 tst.b flag_scrolling
 beq .scrolling_termin�
 
 move mousex_118,souris_x
 move mousey_118,souris_y

**************** Le scrolling vers la gauche

 move souris_x,d0
 cmp #16,d0
 bpl.s .pas_scroll_gauche
 moveq #16,d1
 sub d0,d1
 sub d1,x_scroll
 bpl.s .pas_scroll_gauche
 clr x_scroll
.pas_scroll_gauche

**************** Le scrolling vers la droite

 move largeur_visible,d7
 lsr d7				Largeur en pixels
 subq #1,d7			Coordonn�e du dernier pixel � droite.

 move souris_x,d0
 move d7,d6
 sub #16,d6			Coordonn�e du 16�me pixel partant de droite.
 cmp d6,d0
 ble.s .pas_scroll_droite
 sub d6,d0
 add d0,x_scroll
 move largeur_�cran,d0
 sub largeur_visible,d0
 lsr d0
 cmp x_scroll,d0
 bge.s .pas_scroll_droite
 move d0,x_scroll		* Normalement, 40 pixels (360-320)
.pas_scroll_droite

**************** Le scrolling vers le haut

 move souris_y,d0
 cmp #16,d0
 bpl.s .pas_scroll_haut
 tst y_scroll
 beq.s .pas_scroll_haut
 moveq #16,d1
 sub d0,d1
 sub d1,y_scroll
 bpl.s .pas_scroll_haut
 clr y_scroll
.pas_scroll_haut

**************** Le scrolling vers le bas

 move hauteur_visible,d7
* subq #1,d7			Coordonn�e du dernier pixel en bas

 move souris_y,d0
 move d7,d6
 sub #16+1,d6			Coordonn�e du 16�me pixel partant du bas
 cmp d6,d0
 ble.s .pas_scroll_bas
 sub d6,d0
 add d0,y_scroll
 move hauteur_�cran,d0
 sub d7,d0			hauteur_visible
 cmp y_scroll,d0
 bge.s .pas_scroll_bas
 move d0,y_scroll		* Normalement, 40 pixels (360-320)
.pas_scroll_bas

.scrolling_termin�
 bsr d�place_�cran 
 rts


d�place_�cran
 move.l �cran,d0
 move y_scroll,d1
 muls largeur_�cran,d1
 add.l d1,d0
 move x_scroll,d1
 bclr #0,d1			Que tous les 2 pixels !
 ext.l d1
 add.l d1,d1
 add.l d1,d0
 move.l d0,�cran_scroll
 rts

d�brayage_scrolling
 not.b flag_scrolling
 bsr s�lecteur_informations
 rts


   
 DATA
 
 even
 
choix_moniteur
 dc.l txt_moniteur_monochrome
 dc.l txt_moniteur_couleur
 dc.l txt_moniteur_vga
 dc.l txt_moniteur_broadcast
 
txt_moniteur_monochrome	dc.b "VISU N&B",0
txt_moniteur_couleur	dc.b "VISU COULEUR",0
txt_moniteur_vga	dc.b "MONITEUR VGA",0
txt_moniteur_broadcast	dc.b "T�L�VISION",0

 even

 
 BSS

 even
 
type_moniteur		ds.w 1
mode_r�solution		ds.w 1 
flag_double_largeur	ds.w 1
flag_double_hauteur	ds.w 1
flag_overscan		ds.w 1
flag_vga		ds.w 1
flag_scrolling		ds.w 1

linewidth		ds.w 1
sauve_vco		ds.w 1

x_scroll		ds.w 1
y_scroll		ds.w 1

souris_x		ds.w 1
souris_y		ds.w 1

largeur_visible		ds.w 1
hauteur_visible		ds.w 1
�cran_scroll		ds.l 1

sauve_9800		ds.l 1
sauve_linewidth		ds.w 1

dim_largeur_�cran	ds.w 1
dim_hauteur_�cran	ds.w 1
dim_largeur_visible	ds.w 1
dim_hauteur_visible	ds.w 1
dim_mode_r�solution	ds.w 1
dim_linewidth		ds.w 1
dim_taille_�cran	ds.l 1
