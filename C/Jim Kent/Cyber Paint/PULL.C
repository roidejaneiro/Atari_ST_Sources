/* :ts=3 */
#include "jimk.h"
#include "flicmenu.h"


WORD *draw_pull(), *save_behind();
static char *pfstack;	/* pfree stack */

WORD *
paskmem(amount)
WORD amount;
{
WORD *pt;

amount += sizeof(WORD);
pt = (WORD *)pfstack;
pfstack += amount;
*pt = amount;
return(pt+1);
}

pfreemem(pt)
WORD *pt;
{
pt -= 1;
pfstack -= *pt;
}

static
max_pull_mem(p)
register Pull *p;
{
WORD max, acc;

max = 0;
while (p)
	{
	acc = Raster_block(p->width, p->height);
	if (acc > max)
		max = acc;
	p = p->next;
	}
return(max);
}

init_pulls(p)	/* figure out how much memory pop-downs could require and reserve
					it separate from rest of memory pool */
Pull *p;
{
long acc;
long maxalloc;
Pull *p1;
Pull *p2;

p1 = p->children;
while (p1 != NULL)
	{
	p2 = p1->children;
	acc = Raster_block(p2->width, p2->height) + max_pull_mem(p2->children);
	if (acc > maxalloc)
		maxalloc = acc;
	p1 = p1->next;
	}
maxalloc += Raster_block(p->width, p->height) + 
	3*sizeof(WORD);
if ((pfstack = (char *)laskmem(maxalloc)) == NULL)
	return(0);
return(1);
}

in_pblock(x, y, p)
int x, y;
register Pull *p;
{
if (mouse_x >= x && mouse_y >= y)
	{
	x += p->width;
	y += p->height;
	if (mouse_x <= x && mouse_y <= y)
		return(1);
	}
return(0);
}

init_menu_colors()
{
vst_color(handle, gemctable[white]);
vswr_mode(handle, 2);
}

pull_color(x, y, p)
int x, y;
register Pull *p;
{
extern WORD diamond_cursor[];
register WORD color;

color = (int)p->data;
colrop(color, x, y, p->width-1, p->height-1);
if (color == ccolor)
	cdraw_brush(diamond_cursor,
		x+(p->width>>1)-1, y + (p->height>>1)-1, oppositec[color] );
}


pull_block(x, y, p)
int x, y;
register Pull *p;
{
colrop(sblack, x, y, p->width-1, p->height-2);
hline(y + p->height-1, x, x + p->width-1, swhite);
}

pull_oblock(x, y, p)
int x, y;
register Pull *p;
{
int x1, y1;

colrop(black, x+1, y+1, p->width-3, p->height-3);
x1 = x + p->width - 1;
y1 = y + p->height - 1;
hline(y, x, x1, white);
hline(y1, x, x1, white);
vline(x, y, y1, white);
vline(x1, y, y1, white);
}

pull_text(x, y, p)
int x, y;
Pull *p;
{
col_pull_text(x, y, p, white);
}

spull_text(x, y, p)
int x, y;
Pull *p;
{
col_pull_text(x, y, p, swhite);
}

col_pull_text(x, y, p, color)
int x, y;
register Pull *p;
int color;
{
extern WORD handle;

vst_color(handle, gemctable[color]);
vswr_mode(handle, 2);
v_gtext(handle, x, y+7, p->data);
}

pull_brush(x, y, p)
int x, y;
register Pull *p;
{
int brush;

brush = (int)p->data;
if (brush == brush_ix)
	colrop(red, x, y, p->width-1, p->height-1);
draw_brush(brushes[brush], x+3, y+2, white);
}

top_print(s)
char *s;
{
pull_block(root_pull.xoff, root_pull.yoff, &root_pull);
vst_color(handle, gemctable[swhite]);
vswr_mode(handle, 2);
v_gtext(handle, 0, 7, s);
}

top_line(s)
char *s;
{
WORD *abehind;

unzoom();
hide_mouse();
if ((abehind = save_behind(root_pull.xoff, root_pull.yoff, &root_pull)) == NULL)
	return;	/* out of memory dudes */
top_print(s);
if (cscreen != pscreen)
	{
	copy_words(cscreen, pscreen, 80*10);
	}
wait_a_jiffy(20);	/* 1/3 second before mouse move makes it go away */
show_mouse();
for (;;)
	{
	check_input();
	if (mouse_moved)
		break;
	if (key_hit)
		{
		reuse_input();
		break;
		}
	}
undraw_pull(root_pull.xoff, root_pull.yoff, &root_pull, abehind);
rezoom();
}

/* reset things some so can draw on physical screen in spite of zoom */
unzoom()
{
hide_mouse();
if (zoom_flag)	/* do some re-arranging so pulldowns are in our screen */
	{
	zbuf_to_screen();
	draw_on_screen();
	show_mouse();
	}
else
	{
	copy_screen(pscreen, bscreen);
	}
zscale_cursor = 0;
show_mouse();
}

rezoom()
{
hide_mouse();
if (zoom_flag)	/* put things back for zoom maybe */
	{
	zscale_cursor = 1;
	draw_on_buffer();
	zbuf_to_screen();
	}
else
	{
	copy_screen(bscreen, pscreen);
	}
show_mouse();
}

#ifdef LATER
init_menu_colors()
{
vst_color(handle, gemctable[white]);
vswr_mode(handle, 2);
}
#endif LATER


static WORD cx, cy; /* offset of "menu" level lettering aka amiga terminology */
static WORD ccx, ccy; /* offset of drop downs */
static WORD sx, sy;	/* offset of selection */
static Pull *cchild;
static Pull *select;	
WORD menu_down;
WORD sel_hi;
WORD *abehind, *bbehind, *cbehind; /*buffers for
												menu-bar, drop-down, and
												hilit selection */

static unselect()
{
if (select)
	{
	undraw_pull(sx, sy, select, cbehind);
	select = NULL;
	sel_hi = -1;
	}
}

static unchild()
{
unselect();
if (cchild)
	{
	undraw_pull(ccx, ccy,  cchild, bbehind);
	cchild = NULL;
	menu_down = -1;
	}
}

pull(p)
Pull *p;
{
WORD cline_size, cbehind_size;  /* dimensions of hilight box in bytes */
WORD x, y;  /* root offset */
WORD i, j;
Pull *child;
Pull *scratch;
WORD scx, scy;	/* scratch (selection) offset */
WORD pulled = -1;	/* the result */
unsigned char c;
Pull *p;

/* save color map */
select = cchild = NULL;
menu_down = sel_hi = -1;
abehind = bbehind = cbehind = NULL;
x = p->xoff;
y = p->yoff;
hide_mouse();
abehind = draw_pull(x, y, p);
for (;;)
	{
	check_input();
	if (zoom_flag && check_zoom())
		{
		unchild();
		hide_mouse();
		see_top_lines();
		show_mouse();
		}
	else if (key_hit)
		{
		reuse_input();
		unchild();
		break;
		}
	else if (RJSTDN)
		{
		unchild();
		break;
		}
	else
		{
		child = p->children;
		i = 0;
		while (child)
			{
			cx = x + child->xoff;
			cy = y + child->yoff;
			if (in_pblock(cx, cy, child))
				{
				if (menu_down != i)
					{
					unchild();
					if ((cchild = child->children) != NULL)
						{
						ccx = cx + cchild->xoff;
						ccy = cy + cchild->yoff;
						if ((bbehind =  draw_pull(ccx, ccy, cchild) ) == NULL)
							{
							goto outta_pul;
							}
						}
					menu_down = i;
					}
				break;
				}
next_child:
			child = child->next;
			i++;
			}
		if (cchild  != NULL)
			{
			if (in_pblock(ccx, ccy, cchild))
				{
				scratch = cchild->children;
				j = 0;
				while (scratch)
					{
					scx = ccx + scratch->xoff;
					scy = ccy + scratch->yoff;
					if (in_pblock(scx, scy, scratch))
						{
						if (sel_hi != j)
							{
							unselect();
							select = scratch;
							sx = scx;
							sy = scy;
							sel_hi = j;
							cline_size = cbehind_size = Raster_line(scratch->width);
							cbehind_size *= scratch->height;
							if ( (cbehind = paskmem(cbehind_size) ) == NULL)
								{
								goto outta_pul;
								}
							hide_mouse();
							copy_blit(scratch->width, scratch->height, scx, scy, 
							   cscreen,  160, 
								0, 0, cbehind, cline_size);
							draw_frame(red, scx, scy, scx+scratch->width-1,
								scy+scratch->height-1);
							show_mouse();
							}
						if (PJSTDN)
							{
							if (select != NULL)
								{
								if (in_pblock(sx, sy, select))
									{
									pulled = (menu_down<<8)+sel_hi;
									unchild();
									}
								}
							unchild();
							wait_penup();
							}
						goto end_one_input;
						}
					scratch = scratch->next;
					j++;
					}
				}
			}
		if (PJSTDN)
			{
			unchild();
			wait_penup();
			}
		}
end_one_input:
	;
	}
outta_pul:
unchild();
undraw_pull(x, y,  p, abehind);
if (RDN)
	wait_rup();
return(pulled);
}

whipe_pull(x, y, p)
register int x, y;
register Pull *p;
{
if (p == NULL)
	return;
hide_mouse();
erase_seg(y, p->height);
show_mouse();
}

see_pull(x, y, p)
register int x, y;
register Pull *p;
{
if (p == NULL)
	return;
hide_mouse();
(*p->see)(x, y, p);
p = p->children;
while (p)
	{
	(*p->see)(x + p->xoff, y+p->yoff, p);
	p = p->next;
	}
show_mouse();
}

undraw_pull(x, y, p, abehind)
register int x, y;
register Pull *p;
WORD *abehind;
{
WORD abehind_size;
WORD aline_size;

aline_size = abehind_size = Raster_line(p->width);
abehind_size *= p->height;
hide_mouse();
copy_blit(p->width, p->height, 0, 0, abehind, aline_size,
	x, y, cscreen, 160);
show_mouse();
pfreemem(abehind);
}

WORD *
save_behind(x, y, p)
register int x, y;
register Pull *p;
{
WORD *abehind;
WORD abehind_size;
WORD aline_size;

aline_size = abehind_size = Raster_line(p->width);
abehind_size *= p->height;
if ( (abehind = paskmem(abehind_size) ) == NULL)
	return(NULL);	/* not enough memory */
copy_blit(p->width, p->height, x, y, cscreen,  160, 
	0, 0, abehind, aline_size);
return(abehind);
}


WORD *
draw_pull(x, y, p)
register int x, y;
register Pull *p;
{
WORD *abehind;

hide_mouse();
if ((abehind = save_behind(x, y, p)) == NULL)
	return(NULL);	/* not enough memory */
(*p->see)(x, y, p);
p = p->children;
while (p)
	{
	(*p->see)(x + p->xoff, y+p->yoff, p);
	p = p->next;
	}
show_mouse();
return(abehind);
}

unxmenu(p)
register Pull *p;
{
while (p)
	{
	p->data[0] = ' ';
	p = p->next;
	}
}

xone(p, one)
register Pull *p;
register int one;
{
while (--one >= 0)
	p = p->next;
p->data[0] = 175;
}

xonflag(p, flag)
register Pull *p;
WORD flag;
{
if (flag)
	p->data[0] = 175;
else
	p->data[0] = ' ';
}
