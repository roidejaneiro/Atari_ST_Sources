/*
	Tabulatorweite: 3
	Kommentare ab: Spalte 60											*Spalte 60*
*/

#include	<Types2B.h>

#ifndef	__ESM_IMAGE__
#define	__ESM_IMAGE__

#define	ESM_MONOCHROME	
#define	ESM_GRAYSCALE	2

typedef struct
{
	int32	magic;															/* 'TMS\0' */
	int16	size;																/* L�nge des Headers in Bytes (0x032c) */

	int16	width;															/* Breite in Pixeln */
	int16	height;															/* H�he in Zeilen */

	int16	planes;															/* Bits pro Pixel */
	int16	format;															/* Bildtyp */

	int16	r_bits;															/* Anzahl der Bits f�r Rot */
	int16	g_bits;															/* Anzahl der Bits f�r Gr�n */
	int16	b_bits;															/* Anzahl der Bis f�r Blau */
	int16	k_bits;															/* Anzahl der Bits f�r Schwarz (??) */	

	int16	version;															/* Versionsnummer */
	int16	hdpi;																/* horizontale Aufl�sung in dpi */
	int16	vdpi;																/* vertikale Aufl�sung in dpi */

	int16	file_height;
	int16	y1;																/* erste anzuzeigende Zeile */
	int16	y2;																/* letzte anzuzeigende Zeile */

	int16	mask;																/* Maske */

	uint8	red[256];														/* Rot-Intensit�ten */
	uint8	green[256];														/* Gr�n-Intensit�ten */
	uint8	blue[256];														/* Blau-Intensit�ten */

} ESM_HEAD;

#endif




