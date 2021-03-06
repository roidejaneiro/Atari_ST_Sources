

/********************************************************************************/
/* REMARK: set tab width to 4 spaces for best format							*/
/********************************************************************************/
/********************************************************************************/
/* 																				*/
/* Copyright (C) 1992	All Rights Reserved										*/
/* Centre de Recherche Public Henri Tudor (CRP-HT)								*/
/* 6, rue Coudenhove-Kalergi													*/
/* L1359 Luxembourg-Kirchberg													*/
/* 																				*/
/* Author			: Schmit Rene												*/
/* Internet			: Rene.Schmit@crpht.lu										*/
/* Creation Date	: Friday, October 02 1992 									*/
/* File name		: AVL_TREE.C												*/
/* Project			: Library													*/
/* 																				*/
/* This software may be copied, distributed, ported and modified in source or	*/
/* object format as long as :													*/
/* 																				*/
/* 	1) No distribution for commercial purposes is made.							*/
/* 	2) No third-party copyrights (such as runtime licenses) are involved		*/
/* 	3) This copyright notice is not removed or changed.							*/
/* 																				*/
/* No responsibility is assumed for any damages that may result 				*/
/* from any defect in this software.											*/
/* 																				*/
/********************************************************************************/
/********************************************************************************/

/*
	Main file of the AVL_TREE library
*/

#include <ctype.h>
#include <limits.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "memalpha.h"


/********************************************************************************/
/******************************* Constants **************************************/
/********************************************************************************/

#define true 1
#define false 0

#ifndef NULL
#define NULL 0
#endif


/********************************************************************************/
/******************************* Data Types *************************************/
/********************************************************************************/

enum t_Balance 
{
	c_Left,
	c_Equal,
	c_Right
};

typedef enum t_Balance t_Balance;

/********************************************************************************/

struct t_AlphaBlockTreeNode 
{
	t_BlockDescriptor*					f_Element;
	t_Balance						f_Balance;
	struct t_AlphaBlockTreeNode *	f_Left;
	struct t_AlphaBlockTreeNode *	f_Right;
};

typedef struct t_AlphaBlockTreeNode t_AlphaBlockTreeNode;

/********************************************************************************/
/**************************** File global data **********************************/
/********************************************************************************/

static	t_AlphaBlockTreeNode	  *	g_HelpAlphaBlockNode;

static	t_AlphaBlockTreeNode	  *	g_SpareAlphaBlockNode;

static	t_AlphaBlockTreeNode	  * g_Root;

/********************************************************************************/
/*********************** Local function prototypes ******************************/
/********************************************************************************/

static	int 						check_AlphaBlockEmpty		  (	t_AlphaBlockTreeNode  *	p_Tree);

static	int							AlphaBlock_max	  	 		  (	int p_x,
																	int p_y
																  );

static	t_AlphaBlockTreeNode	  *	balance_AlphaBlockLeft		  (	t_AlphaBlockTreeNode  *	p_Tree,
																	int 				  *	p_Higher
																  );
static	t_AlphaBlockTreeNode	  *	balance_AlphaBlockRight	 	  (	t_AlphaBlockTreeNode  *	p_Tree,
																	int 				  * p_Higher
																  );
static	t_AlphaBlockTreeNode	  *	eliminate_AlphaBlock		  (	t_AlphaBlockTreeNode  * p_Tree,
																	int					  * p_Higher
																  );

static t_AlphaBlockTreeNode		  *	insert_AlphaBlock_into_Tree1  (	t_AlphaBlockTreeNode  *	p_Tree,
																	t_BlockDescriptor*			p_data,
																	int *p_Higher
																  );

static int							search_AlphaBlock_in_Tree1	  (	t_AlphaBlockTreeNode  * p_Tree,
																	t_BlockDescriptor*		  * p_data
																  );

static t_AlphaBlockTreeNode		  *	remove_AlphaBlock_from_Tree1  (	t_AlphaBlockTreeNode  *	p_Tree,
																	t_BlockDescriptor*			p_data,
																	int					  *	p_Higher
																  );

static void 						delete_AlphaBlockTree1		  (	t_AlphaBlockTreeNode **	p_Tree);
static int							get_Height_of_AlphaBlockTree1 (	t_AlphaBlockTreeNode  *	p_Tree);
static int							get_Card_of_AlphaBlockTree1	  (	t_AlphaBlockTreeNode  *	p_Tree);


static void							free_AlphaBlockTree1	  (	t_AlphaBlockTreeNode	  *	p_Tree);

static void							print_AlphaBlockTree1	  (	t_AlphaBlockTreeNode	  *	p_Tree);

/********************************************************************************/
/**************************** Local functions ***********************************/
/********************************************************************************/

static int check_AlphaBlockEmpty(t_AlphaBlockTreeNode *p_Tree)
{
	if (p_Tree == NULL)
		return (true);
	else
		return (false);
}


/********************************************************************************/

static int AlphaBlock_max	  (	int p_x,
								int p_y
							  )

{
	if (p_x > p_y)
		return p_x;
	else
		return p_y;
}

/********************************************************************************/

static t_AlphaBlockTreeNode	  *	insert_AlphaBlock_into_Tree1  (	t_AlphaBlockTreeNode  *	p_Tree,
																t_BlockDescriptor*			p_data,
																int 				  * p_Higher
															  )

{
t_AlphaBlockTreeNode  *	l_Temp1;
t_AlphaBlockTreeNode  *	l_Temp2;

	if (check_AlphaBlockEmpty(p_Tree))
	{
		p_Tree = (t_AlphaBlockTreeNode  *) malloc(sizeof(t_AlphaBlockTreeNode));
		if (p_Tree == NULL)
		{
			p_Tree = g_SpareAlphaBlockNode;
			g_SpareAlphaBlockNode = NULL;
		}
		if (p_Tree == NULL)
			
		{
			treat_InternalError(3);	
			return (NULL);									
		}
		
		p_Tree->f_Element	= p_data ;
		p_Tree->f_Left		= NULL;
		p_Tree->f_Right		= NULL;
		p_Tree->f_Balance	= c_Equal;
		*p_Higher			= true;
	}
	else
	{
		if (compare_Identifiers(p_data,p_Tree->f_Element) < 0)
		{
			p_Tree->f_Left = insert_AlphaBlock_into_Tree1(p_Tree->f_Left,p_data,p_Higher);
			if (*p_Higher)
				switch (p_Tree->f_Balance)
				{
					case c_Left	  : l_Temp1 = p_Tree->f_Left;
									if(l_Temp1->f_Balance == c_Left)
									{
										p_Tree ->f_Left		= l_Temp1->f_Right;
										l_Temp1->f_Right	= p_Tree;
										p_Tree ->f_Balance	= c_Equal;
										p_Tree				= l_Temp1;
									}
									else
									{
										l_Temp2				= l_Temp1->f_Right;
										l_Temp1->f_Right	= l_Temp2->f_Left;
										l_Temp2->f_Left		= l_Temp1;
										p_Tree ->f_Left		= l_Temp2->f_Right;
										l_Temp2->f_Right	= p_Tree;
										
										if (l_Temp2->f_Balance == c_Left)
											p_Tree->f_Balance = c_Right;
										else
											p_Tree->f_Balance = c_Equal;
											
										if (l_Temp2->f_Balance == c_Right)
											l_Temp1->f_Balance = c_Left;
										else
											l_Temp1->f_Balance = c_Equal;
											
										p_Tree = l_Temp2;
									}
									p_Tree->f_Balance	= c_Equal;
									*p_Higher			= false;
									break;
										
					case c_Equal  : p_Tree->f_Balance	= c_Left;
									break;
										
					case c_Right  : p_Tree->f_Balance	= c_Equal;
									*p_Higher			= false;
									break;
				}
		}
		else
			if (compare_Identifiers(p_data,p_Tree->f_Element) > 0)
			{
				p_Tree->f_Right = insert_AlphaBlock_into_Tree1(p_Tree->f_Right,p_data,p_Higher);
				if (*p_Higher)
					switch (p_Tree->f_Balance)
					{
						case c_Left	  : p_Tree->f_Balance	= c_Equal;
										*p_Higher			= false;
										break;

						case c_Equal  : p_Tree->f_Balance	= c_Right;
										break;
											
						case c_Right  : l_Temp1 = p_Tree->f_Right;
										if(l_Temp1->f_Balance == c_Right)
										{
											p_Tree->f_Right		= l_Temp1->f_Left;
											l_Temp1->f_Left		= p_Tree;
											p_Tree->f_Balance	= c_Equal;
											p_Tree				= l_Temp1;
										}
										else
										{
											l_Temp2				= l_Temp1->f_Left;
											l_Temp1->f_Left		= l_Temp2->f_Right;
											l_Temp2->f_Right	= l_Temp1;
											p_Tree ->f_Right	= l_Temp2->f_Left;
											l_Temp2->f_Left		= p_Tree;
											
											if (l_Temp2->f_Balance == c_Right)
												p_Tree->f_Balance =	c_Left;
											else
												p_Tree->f_Balance =	c_Equal;
											
											if (l_Temp2->f_Balance == c_Left)
												l_Temp1->f_Balance = c_Right;
											else
												l_Temp1->f_Balance = c_Equal;
												
											p_Tree = l_Temp2;
										}
										p_Tree->f_Balance= c_Equal;
										*p_Higher = false;
										break;
											
					}
		}
		else
		{
			*p_Higher = false;
		
			treat_InternalError(1);
			return (p_Tree) ;								
		
		}
	}
	return (p_Tree);
}

/********************************************************************************/

static t_AlphaBlockTreeNode	  *	balance_AlphaBlockRight	(	t_AlphaBlockTreeNode  * p_Tree,
															int					  * p_Higher
														)
											
{
t_AlphaBlockTreeNode  *	l_Temp1;
t_AlphaBlockTreeNode  *	l_Temp2;
t_Balance				l_Balance1;
t_Balance				l_Balance2;

	switch(p_Tree->f_Balance)
	{
		case c_Left		  :	p_Tree->f_Balance	= c_Equal;
							break ;
							
		case c_Equal	  :	p_Tree->f_Balance	= c_Right;
							* p_Higher			= false;
							break ;
							
		case c_Right	  :	l_Temp1		= p_Tree->f_Right;
							l_Balance1	= l_Temp1->f_Balance;
							if (l_Balance1 >= c_Equal)
							{
								p_Tree->f_Right = l_Temp1->f_Left;
								l_Temp1->f_Left = p_Tree;
								
								if (l_Balance1 == c_Equal)
								{
									p_Tree->f_Balance	= c_Right;
									l_Temp1->f_Balance	= c_Left;
									*p_Higher			= false;
								}
								else
								{
									p_Tree->f_Balance	= c_Equal;
									l_Temp1->f_Balance	= c_Equal;
								}
								p_Tree = l_Temp1;
							}
							else
							{
								l_Temp2				= l_Temp1->f_Left;
								l_Balance2			= l_Temp2->f_Balance;
								l_Temp1->f_Left		= l_Temp2->f_Right;
								l_Temp2->f_Right	= l_Temp1;
								p_Tree ->f_Right	= l_Temp2->f_Left;
								l_Temp2->f_Left		= p_Tree;
								
								if (l_Balance2 == c_Right)
									p_Tree ->f_Balance	= c_Left;
								else
									p_Tree ->f_Balance	= c_Equal;
								
								if (l_Balance2 == c_Left )
									l_Temp1->f_Balance	= c_Right;
								else
									l_Temp1->f_Balance	= c_Equal;
								
								p_Tree				= l_Temp2;
								l_Temp2->f_Balance	= c_Equal;
							}
							break ;
	}
	return(p_Tree);
}

/********************************************************************************/

static t_AlphaBlockTreeNode	  *	balance_AlphaBlockLeft	(	t_AlphaBlockTreeNode  * p_Tree,
															int					  * p_Higher
														)
											
{
t_AlphaBlockTreeNode  *	l_Temp1;
t_AlphaBlockTreeNode  *	l_Temp2;
t_Balance				l_Balance1;
t_Balance				l_Balance2;

	switch(p_Tree->f_Balance)
	{
		case c_Left		  :	l_Temp1		= p_Tree->f_Left;
							l_Balance1	= l_Temp1->f_Balance;
							if (l_Balance1 <= c_Equal)
							{
								p_Tree->f_Left		= l_Temp1->f_Right;
								l_Temp1->f_Right	= p_Tree;
								
								if (l_Balance1 == c_Equal)
								{
									p_Tree->f_Balance	= c_Left;
									l_Temp1->f_Balance	= c_Right;
									*p_Higher			= false;
								}
								else
								{
									p_Tree->f_Balance	= c_Equal;
									l_Temp1->f_Balance	= c_Equal;
								}
								p_Tree = l_Temp1;
							}
							else
							{
								l_Temp2				= l_Temp1->f_Right;
								l_Balance2			= l_Temp2->f_Balance;
								l_Temp1->f_Right	= l_Temp2->f_Left;
								l_Temp2->f_Left		= l_Temp1;
								p_Tree ->f_Left		= l_Temp2->f_Right;
								l_Temp2->f_Right	= p_Tree;
								
								if (l_Balance2 == c_Left) 
									p_Tree ->f_Balance	= c_Right;
								else
									p_Tree ->f_Balance	= c_Equal;
									
								if (l_Balance2 == c_Right)
									l_Temp1->f_Balance	= c_Left;
								else
									l_Temp1->f_Balance	= c_Equal;
								
								p_Tree				= l_Temp2;
								l_Temp2->f_Balance	= c_Equal;
							}
							break ;

		case c_Equal	  :	p_Tree->f_Balance	= c_Left;
							* p_Higher			= false;
							break ;
							
		case c_Right	  :	p_Tree->f_Balance	= c_Equal;
							break ;
	}
	return(p_Tree);
}


/********************************************************************************/

static	t_AlphaBlockTreeNode	  *	eliminate_AlphaBlock	  (	t_AlphaBlockTreeNode  * p_Tree,
																int					  * p_Higher
															  )
																  
{
	if (!(check_AlphaBlockEmpty(p_Tree->f_Right)))
	{
		p_Tree->f_Right = eliminate_AlphaBlock(p_Tree->f_Right,p_Higher);
		if (*p_Higher)
			p_Tree = balance_AlphaBlockLeft(p_Tree,p_Higher);
	}
	else
	{
	t_AlphaBlockTreeNode	  * l_ObsoleteNode;
	
		l_ObsoleteNode = p_Tree;
		g_HelpAlphaBlockNode->f_Element = p_Tree->f_Element;
		p_Tree							= p_Tree->f_Left;
		free(l_ObsoleteNode);
		*p_Higher						= true;
	}
	return p_Tree;
}

/********************************************************************************/

static t_AlphaBlockTreeNode  *	remove_AlphaBlock_from_Tree1  (	t_AlphaBlockTreeNode  *	p_Tree,
																t_BlockDescriptor*			p_data,
																int					  *	p_Higher
															  )

{
	if (check_AlphaBlockEmpty(p_Tree))
	{
		*p_Higher = false;
			
				treat_InternalError(2);
				return (p_Tree);									
			
	}
	else
		if (compare_Identifiers(p_data,p_Tree->f_Element) < 0)
		{
			p_Tree->f_Left = remove_AlphaBlock_from_Tree1(p_Tree->f_Left,p_data,p_Higher);
			if (*p_Higher)
				p_Tree = balance_AlphaBlockRight(p_Tree,p_Higher);
		}
		else
			if (compare_Identifiers(p_data,p_Tree->f_Element) > 0)
			{
				p_Tree->f_Right = remove_AlphaBlock_from_Tree1(p_Tree->f_Right,p_data,p_Higher);
				if (*p_Higher)
					p_Tree = balance_AlphaBlockLeft(p_Tree,p_Higher);
			}
			else
			{
				g_HelpAlphaBlockNode = p_Tree;
				if (check_AlphaBlockEmpty(g_HelpAlphaBlockNode->f_Right))
				{
					p_Tree		= g_HelpAlphaBlockNode->f_Left;
					free(g_HelpAlphaBlockNode);
					*p_Higher	= true;
				}
				else
					if (check_AlphaBlockEmpty(g_HelpAlphaBlockNode->f_Left))
					{
						p_Tree		= g_HelpAlphaBlockNode->f_Right;
						free(g_HelpAlphaBlockNode);
						*p_Higher	= true;
					}
					else
					{
						g_HelpAlphaBlockNode->f_Left = eliminate_AlphaBlock(g_HelpAlphaBlockNode->f_Left,p_Higher);
						if (*p_Higher)
							p_Tree = balance_AlphaBlockRight(p_Tree,p_Higher);
					}
			}
	return p_Tree;
}

/********************************************************************************/

static	int	search_AlphaBlock_in_Tree1	  (	t_AlphaBlockTreeNode  * p_Tree,
											t_BlockDescriptor*		  * p_data)

{
	if (!(check_AlphaBlockEmpty(p_Tree)))
		if (compare_Identifiers(* p_data,p_Tree->f_Element) < 0)
			return (search_AlphaBlock_in_Tree1(p_Tree->f_Left,p_data));
		else
			if (compare_Identifiers(* p_data,p_Tree->f_Element) > 0)
				return (search_AlphaBlock_in_Tree1(p_Tree->f_Right,p_data));
			else
			{
				*p_data = p_Tree->f_Element;
				return (true);
			}
	else
		return (false);
}

/********************************************************************************/

static void delete_AlphaBlockTree1	(t_AlphaBlockTreeNode	  **	p_Tree)

{
	if (!(check_AlphaBlockEmpty(*p_Tree)))
	{
		delete_AlphaBlockTree1(&((*p_Tree)->f_Left));
		delete_AlphaBlockTree1(&((*p_Tree)->f_Right));
		free(*p_Tree);
		*p_Tree = NULL;
	}
}

/********************************************************************************/

static	int get_Height_of_AlphaBlockTree1(t_AlphaBlockTreeNode *p_Tree)

{
	if (check_AlphaBlockEmpty(p_Tree))
		return 0;
	else
	{
		return	(1 + AlphaBlock_max(	get_Height_of_AlphaBlockTree1(p_Tree->f_Left),
										get_Height_of_AlphaBlockTree1(p_Tree->f_Right)
									)
				);
	}
}

/********************************************************************************/

static	int get_Card_of_AlphaBlockTree1	  (	t_AlphaBlockTreeNode  *	p_Tree)

{
	if (!(check_AlphaBlockEmpty(p_Tree)))
		return	(	1
				+	get_Card_of_AlphaBlockTree1(p_Tree->f_Left)
				+	get_Card_of_AlphaBlockTree1(p_Tree->f_Right)
				);
	else
		return 0;
}



/********************************************************************************/
	
static void	free_AlphaBlockTree1	  (t_AlphaBlockTreeNode  *	p_Tree)

{
	if (!(check_AlphaBlockEmpty(p_Tree)))
	{
		free_AlphaBlockTree1(p_Tree->f_Left);

		delete_Descriptor(p_Tree->f_Element);
	
		free_AlphaBlockTree1(p_Tree->f_Right);
	}
}


/********************************************************************************/
	
static void	print_AlphaBlockTree1	  (t_AlphaBlockTreeNode  *	p_Tree)

{
	if (!(check_AlphaBlockEmpty(p_Tree)))
	{
		print_AlphaBlockTree1(p_Tree->f_Left);

		print_AlphaBlock(p_Tree->f_Element);
	
		print_AlphaBlockTree1(p_Tree->f_Right);
	}
}


/********************************************************************************/
/**************************** Global functions **********************************/
/********************************************************************************/

void	create_AlphaBlockTree ( void )

{
	g_SpareAlphaBlockNode	= (t_AlphaBlockTreeNode  *)		malloc(sizeof(t_AlphaBlockTreeNode	));
	g_Root					= NULL;
}

/********************************************************************************/

void	insert_AlphaBlock_into_Tree	  (	t_BlockDescriptor*			p_data )

{
int l_Dummy = false;
	g_Root = insert_AlphaBlock_into_Tree1 (g_Root,p_data,&l_Dummy);
}

/********************************************************************************/

int	search_AlphaBlock_in_Tree	  (	t_BlockDescriptor*		  * p_data)

{
	return (search_AlphaBlock_in_Tree1(g_Root,p_data));
}

/********************************************************************************/

void	remove_AlphaBlock_from_Tree	  (t_BlockDescriptor*		p_data )

{
int l_Dummy = false;
	g_Root = remove_AlphaBlock_from_Tree1(g_Root,p_data,&l_Dummy);
	if (g_SpareAlphaBlockNode == NULL)
		g_SpareAlphaBlockNode =  (t_AlphaBlockTreeNode  *) malloc(sizeof(t_AlphaBlockTreeNode));
}

/********************************************************************************/

void delete_AlphaBlockTree	( void )

{
	if (g_SpareAlphaBlockNode)
	{
		free(g_SpareAlphaBlockNode);
		g_SpareAlphaBlockNode = NULL;
	}
	delete_AlphaBlockTree1(&g_Root);
}

/********************************************************************************/

int 	check_AlphaBlockFull		( void )

{
	if (g_SpareAlphaBlockNode == NULL)
		g_SpareAlphaBlockNode =  (t_AlphaBlockTreeNode  *) malloc(sizeof(t_AlphaBlockTreeNode));
	return (g_SpareAlphaBlockNode == NULL);
}

/********************************************************************************/

int get_Height_of_AlphaBlockTree	( void )

{
	return (get_Height_of_AlphaBlockTree1	(g_Root));
}

/********************************************************************************/

int get_Card_of_AlphaBlockTree		( void )

{
	return (get_Card_of_AlphaBlockTree1		(g_Root));
}

/********************************************************************************/


	
void	free_AlphaBlockTree	  ( void )

{
	free_AlphaBlockTree1(g_Root);
}

/********************************************************************************/

	
void	print_AlphaBlockTree	  ( void )

{
	print_AlphaBlockTree1(g_Root);
}

/********************************************************************************/

/********************************************************************************/

