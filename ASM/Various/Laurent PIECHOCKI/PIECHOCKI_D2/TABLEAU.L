
          BSS                 ;segment BSS

CONTROL:                      ;tableau CONTROL (':' car il pointe sur une
                              ;adresse et non pas sur une instruction...)
opcode    ds.w      1         ;1� adresse du tableau 'control':opcode
sptsin    ds.w      1         ;2� adresse:sptsin
sptsout   ds.w      1         ;3� adresse:sptsout
sintin    ds.w      1         ;4� adresse:sintin
sintout   ds.w      1         ;5� adresse:sintout
idsfct    ds.w      1         ;6� adresse:idsfct
handle    ds.w      1         ;7� adresse:handle
          ds.w      10

;le tableau CONTROL a une taille de 54 octets.


GLOBAL:                       ;d�but du tableau GLOBAL
apvers    ds.w      1         ;1� adresse du tableau 'global':apvers
apcount   ds.w      1         ;2� adresse:apcount
apid      ds.w      1         ;3� adresse:apid
apprivate ds.l      1         ;4� adresse:apprivate
apptree   ds.l      1         ;5� adresse:apptree
ap1resv   ds.l      1         ;6� adresse:ap1resv
ap2resv   ds.l      1         ;7� adresse:ap2resv
ap3resv   ds.l      1         ;8� adresse:ap3resv
ap4resv   ds.l      1         ;9� adresse:ap4resv

;le tableau GLOBAL a une taille de 30 octets



intin     ds.w      128       ;tableau 'intin':128 mots
     
intout    ds.w      128       ;tableau 'intout':128 mots
     
ptsin     ds.w      128       ;tableau 'ptsint':128 mots

ptsout    ds.w      128       ;tableau 'ptsout':128 mots



addrin    ds.w      128       ;tableau 'addrin' (AES):128 mots

addrout   ds.w      128       ;tableau 'addrout' (AES):128 mots


grhandle  ds.w      1         ;ici on r�serve 1 mot pour le handle


          DS.W      50000
PILE      DS.W      1


          DATA                ;segment DATA

;le vecteur de l'AES
       
          ALIGN.W

aespb     dc.l      control,global,intin,intout,addrin,addrout

;le vecteur du VDI

          ALIGN.W

vdipb     dc.l      control,intin,ptsin,intout,ptsout

          END


 