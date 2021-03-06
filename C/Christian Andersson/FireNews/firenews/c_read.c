#include "firenews.h"
#include "..\info\vaproto\vaproto.h"
/********************************************************************/
/* Initiering av read-f�nstret                                      */
/********************************************************************/
void init_read_win(void)
{
  read_win.text=&read_text;
  strncpy(read_win.w_name,"View Message"/*alerts[WN_READ]*/,MAXWINSTRING);
  strncpy(read_win.w_info,"",MAXWINSTRING);
  read_win.attr=NAME|MOVE|CLOSE|SIZE|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|FULLER|SMALLER;
  read_win.icondata=&icons[ICON_FIRESTORM];
  read_win.status=WINDOW_CLOSED;
  read_win.type=TYPE_TEXT;
  read_win.text->num_of_rows=NOLL;
  read_win.text->num_of_cols=NOLL;
  read_win.text->offset_y=NOLL;
  read_win.text->sc_left=FALSE;
  read_win.text->sc_right=FALSE;
  read_win.text->sc_up=TRUE;
  read_win.text->sc_down=TRUE;
  rsrc_gaddr(R_TREE,MESSAGE_TOP,&read_win.text->dialog);
  read_win.text->dialog[MSGTOP_BAR1].ob_y=0;
  read_win.text->dialog[MSGTOP_BAR2].ob_y=read_win.text->dialog[MSGTOP_BAR1].ob_height;
  read_win.text->dialog[MSGTOP_BAR0].ob_flags|=HIDETREE;
  read_win.text->dialog[MSGTOP_BAR1].ob_flags&=~HIDETREE;
  read_win.text->dialog[MSGTOP_BAR2].ob_flags&=~HIDETREE;
  read_win.text->dialog[MSGTOP_BIGGER1].ob_flags|=HIDETREE;
  read_win.text->dialog[MSGTOP_BIGGER2].ob_flags|=HIDETREE;
  Return;
}

/********************************************************************/
/* �ppnar read-f�nstret                                             */
/********************************************************************/
void open_read_win(void)
{
  active.tempgroup=get_entity(active.glist,active.group_num);
  if(!active.tempgroup)
  {
    Return;
  }
  read_win.tag=active.msg_num;
  
  active.tempmessage=get_entity(active.mlist,active.msg_num);
  if(!active.tempmessage)
  {
    Return;
  }
  if(active.tempmessage->flags.header_only)
  {
	if(read_win.status!=WINDOW_CLOSED)
	  close_readwin();
  
    if(active.tempmessage->flags.new)
      change_flag(active.msg_num,MSG_FLAG_NEW,FALSE);
    if(alertbox(1,alerts[Q_REQUEST])==1)
      change_flag(active.msg_num,MSG_FLAG_REQ,TRUE);
    if(active.tempmessage->flags.deleted)
      change_flag(active.msg_num,MSG_FLAG_DEL,FALSE);
    list_mark(&msglist_win,msg2list(active.msg_num),TRUE);
    Return;
  }
  if(load_message()==FAIL)
  {
    alertbox(1,alerts[E_LOAD_MESSAGE]);
    close_readwin();
    Return;
  }
  if(active.tempmessage->flags.new)
    change_flag(active.msg_num,MSG_FLAG_NEW,FALSE);
  list_mark(&msglist_win,msg2list(active.msg_num),TRUE);

  top_of_document();
  
  if(!config.hide_header)
  {
    read_win.text->textstart=active.msg_text;
    button(&read_win, MSGTOP_HEADER, SET_STATE, SELECTED,TRUE);
  }
  else
  {
    read_win.text->textstart=active.body_text;
    button(&read_win, MSGTOP_HEADER, CLEAR_STATE, SELECTED,TRUE);
  }
  if(*tempvar.homepage!=0)
    button(&read_win, MSGTOP_URL, CLEAR_STATE, DISABLED,TRUE);
  else
    button(&read_win, MSGTOP_URL, SET_STATE, DISABLED,TRUE);

  read_win.text->offset_y=read_win.text->offset_x=NOLL;
  read_win.text->font_id=font.readid;
  read_win.text->font_size=config.readfontsize;

  open_dialog(&read_win,tempconf.readw_xy);

  Return;
}
/********************************************************************/
/********************************************************************/
void close_readwin()
{
  if(read_win.status!=WINDOW_CLOSED)
  {
    if(read_win.status==WINDOW_OPENED)
      wind_get(read_win.ident,WF_CURRXYWH,&tempconf.readw_xy[X],&tempconf.readw_xy[Y],&tempconf.readw_xy[W],&tempconf.readw_xy[H]);
    else if(read_win.status==WINDOW_ICONIZED)
      wind_get(read_win.ident,WF_UNICONIFY,&tempconf.readw_xy[X],&tempconf.readw_xy[Y],&tempconf.readw_xy[W],&tempconf.readw_xy[H]);
    close_dialog(&read_win);
  }
  if(active.msg_text!=NOLL)
  {
    free(active.msg_text),active.msg_text=NOLL;
  }
  active.tempgroup=get_entity(active.glist,active.group_num);
  if(!active.tempgroup)
  {
    Return;
  }
}
/********************************************************************/
/* Hantering av read-f�nstret                                       */
/********************************************************************/
void check_read_win(RESULT svar)
{
  int dummy;
  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_readwin();
  }
  else if(svar.type==DIALOG_CLICKED)
  {
    switch(svar.data[SVAR_OBJECT])
    {
      case MSGTOP_SMALLER1:
      case MSGTOP_SMALLER2:
      case MSGTOP_BIGGER1:
      case MSGTOP_BIGGER2:
      {
        switch(svar.data[SVAR_OBJECT])
        {
          case MSGTOP_SMALLER1:
          {
            button(&read_win, MSGTOP_SMALLER1, CLEAR_STATE, SELECTED,FALSE);
            read_win.text->dialog[MSGTOP_BAR1].ob_flags|=HIDETREE;
            read_win.text->dialog[MSGTOP_BIGGER1].ob_flags&=~HIDETREE;
            break;
          }
          case MSGTOP_SMALLER2:
          {
            button(&read_win, MSGTOP_SMALLER2, CLEAR_STATE, SELECTED,FALSE);
            read_win.text->dialog[MSGTOP_BAR2].ob_flags|=HIDETREE;
            read_win.text->dialog[MSGTOP_BIGGER2].ob_flags&=~HIDETREE;
            break;
          }
          case MSGTOP_BIGGER1:
          {
            button(&read_win, MSGTOP_BIGGER1, CLEAR_STATE, SELECTED,FALSE);
            read_win.text->dialog[MSGTOP_BAR1].ob_flags&=~HIDETREE;
            read_win.text->dialog[MSGTOP_BIGGER1].ob_flags|=HIDETREE;
            break;
          }
          case MSGTOP_BIGGER2:
          {
            button(&read_win, MSGTOP_BIGGER2, CLEAR_STATE, SELECTED,FALSE);
            read_win.text->dialog[MSGTOP_BAR2].ob_flags&=~HIDETREE;
            read_win.text->dialog[MSGTOP_BIGGER2].ob_flags|=HIDETREE;
            break;
          }
        }
        if((read_win.text->dialog[MSGTOP_BIGGER1].ob_flags&HIDETREE)&&(read_win.text->dialog[MSGTOP_BIGGER2].ob_flags&HIDETREE))
          read_win.text->dialog[MSGTOP_BAR0].ob_flags|=HIDETREE;
        else
          read_win.text->dialog[MSGTOP_BAR0].ob_flags&=~HIDETREE;

        dummy=0;
        if(!(read_win.text->dialog[MSGTOP_BIGGER1].ob_flags&HIDETREE))
        {
          read_win.text->dialog[MSGTOP_BIGGER1].ob_x=dummy;
          dummy+=read_win.text->dialog[MSGTOP_BIGGER1].ob_width+4;
        }
        if(!(read_win.text->dialog[MSGTOP_BIGGER2].ob_flags&HIDETREE))
        {
          read_win.text->dialog[MSGTOP_BIGGER2].ob_x=dummy;
          dummy+=read_win.text->dialog[MSGTOP_BIGGER2].ob_width+4;
        }

        dummy=0;
        if(!(read_win.text->dialog[MSGTOP_BAR0].ob_flags&HIDETREE))
        {
          read_win.text->dialog[MSGTOP_BAR0].ob_y=dummy;
          dummy+=read_win.text->dialog[MSGTOP_BAR0].ob_height;
        }
        if(!(read_win.text->dialog[MSGTOP_BAR1].ob_flags&HIDETREE))
        {
          read_win.text->dialog[MSGTOP_BAR1].ob_y=dummy;
          dummy+=read_win.text->dialog[MSGTOP_BAR1].ob_height;
        }
        if(!(read_win.text->dialog[MSGTOP_BAR2].ob_flags&HIDETREE))
        {
          read_win.text->dialog[MSGTOP_BAR2].ob_y=dummy;
          dummy+=read_win.text->dialog[MSGTOP_BAR2].ob_height;
        }
        read_win.text->dialog[ROOT].ob_height=dummy;
        redraw_window(&read_win);
        break;
      }
      case MSGTOP_REPLY_G:
      {
        create_reply_group(active.msg_num);
        button(&read_win, MSGTOP_REPLY_G, CLEAR_STATE, SELECTED,TRUE);
        break;
      }
      case MSGTOP_REPLY_E:
      {
        create_reply_email(active.msg_num);
        button(&read_win, MSGTOP_REPLY_E, CLEAR_STATE, SELECTED,TRUE);
        break;
      }
      case MSGTOP_SAVE:
      {
        save_message(active.msg_num);
        button(&read_win,MSGTOP_SAVE,CLEAR_STATE,SELECTED,TRUE);
        break;
      }
      case MSGTOP_FORWARD_G:
      {
        button(&read_win,MSGTOP_FORWARD_G,CLEAR_STATE,SELECTED,TRUE);
        break;
      }
      case MSGTOP_FORWARD_E:
      {
        button(&read_win,MSGTOP_FORWARD_E,CLEAR_STATE,SELECTED,TRUE);
        break;
      }
      case MSGTOP_HEADER:
      {
        if(read_win.text->dialog[MSGTOP_HEADER].ob_state&SELECTED)
          read_win.text->textstart=active.msg_text;
        else
          read_win.text->textstart=active.body_text;
        read_win.text->offset_y=read_win.text->offset_x=NOLL;
//        read_win.text->font_id=font.readid;
//        read_win.text->font_size=config.readfontsize;
        open_dialog(&read_win,tempconf.readw_xy);
        break;
      }
      case MSGTOP_URL:
      {
        if(tempvar.registered)
        {
          long strngsrv_id;
          strngsrv_id=appl_find( config.stringserver );
          if(strngsrv_id > FAIL)
          {
            svar.data[0]=(short)VA_START;
            svar.data[1]=(short)ap_id;
            svar.data[2]=(short)0;
            svar.data[3]=(short)tempvar.homepage >> 16;
            svar.data[4]=(short)tempvar.homepage & 0xffff;
            svar.data[5]=(short)0;
            svar.data[6]=(short)0;
            svar.data[7]=(short)0;
            appl_write(strngsrv_id,16,svar.data);
	      }
	    }
        break;
      }
      case MSGTOP_LINKS:
      {
        int charnum;
        NewsHeader *nh;
        charnum=svar.data[SVAR_MOUSE_X]/8;
        ted2str(read_win.text->dialog,MSGTOP_LINKS,tempvar.tempstring);
        if(charnum<strlen(tempvar.tempstring))
        {
          if(tempvar.tempstring[charnum]!=' ')
          {
            while(tempvar.tempstring[charnum]>10)
             charnum--;
            nh=get_entity(active.mlist,active.msg_num);
            if(tempvar.tempstring[charnum]=='')
            {
              if(set_mark(&msglist_win,msg2list(nh->i.parent),TRUE))
              {
                active.msg_num=nh->i.parent;
                change_flag(active.msg_num,MSG_FLAG_TOUCHED,FALSE);
                open_read_win();
              }
            }
            if(tempvar.tempstring[charnum]=='')
            {
              if(set_mark(&msglist_win,msg2list(nh->i.child),TRUE))
              {
                active.msg_num=nh->i.child;
                change_flag(active.msg_num,MSG_FLAG_TOUCHED,FALSE);
                open_read_win();
              }
            }
            if(tempvar.tempstring[charnum]=='')
            {
              if(set_mark(&msglist_win,msg2list(nh->i.next),TRUE))
              {
                active.msg_num=nh->i.next;
                change_flag(active.msg_num,MSG_FLAG_TOUCHED,FALSE);
                open_read_win();
              }
            }
            if(tempvar.tempstring[charnum]=='')
            {
              if(set_mark(&msglist_win,msg2list(nh->i.prev),TRUE))
              {
                active.msg_num=nh->i.prev;
                change_flag(active.msg_num,MSG_FLAG_TOUCHED,FALSE);
                open_read_win();
              }
            }
          }
        }
        break;
      }
    }
  }
  else if(svar.type==TEXT_CLICKED)
  {
    if(svar.data[SVAR_MOUSE_BUTTON]=MO_RIGHT)
    {
      switch(freepopup(alerts[P_MESSAGE],-1,svar.data[SVAR_MOUSE_X],svar.data[SVAR_MOUSE_Y],NULL))
      {
        case 0:  /* Next Message */
          svar.data[SVAR_KEY_SHIFT]=0;
          svar.data[SVAR_KEY_VALUE]=SC_RIGHT*256;
          handle_key(svar);
          break;
        case 1: /* Previous Message */
          svar.data[SVAR_KEY_SHIFT]=0;
          svar.data[SVAR_KEY_VALUE]=SC_LEFT*256;
          handle_key(svar);
          break;
        case 2:  /* seperator */
          break;
        case 3:  /* Reply via e-mail */
          create_reply_email(active.msg_num);
          break;
        case 4:  /* reply to group */
          create_reply_group(active.msg_num);
          break;
        case 5:  /* Seperator */
          break;
        case 6:  /* Delete Message */
          change_flag(active.msg_num,MSG_FLAG_DEL,TRUE);
          top_of_document();
          break;
        case 7:  /* Save Message */
          save_message(active.msg_num);
          break;
        case 8:  /* Seperator */
          break;
        case 9:  /* Set/Delete Flags */
          open_flags_win(FLAGS_SETDEL_READ);
          top_of_document();
          break;
      }
    }
  }
  Return;
}

/********************************************************************/
/********************************************************************/
void top_of_document(void)
{
  NewsHeader *nh;
  nh=get_entity(active.mlist,active.msg_num);
  if(!nh)
  {
    Return;
  }
  if((nh->i.parent==FAIL)&&(nh->i.child==FAIL)&&(nh->i.next==FAIL)&&(nh->i.prev==FAIL))
    str2ted(read_win.text->dialog,MSGTOP_LINKS,"No comments");
  else
  {
    strcpy(tempvar.tempstring,"");
    strcpy(tempvar.temprow1,"");
    if(nh->i.parent!=FAIL)
      sprintf(tempvar.temprow1,"%d ",nh->i.parent+1);
    else
      strcpy(tempvar.temprow1,"");
    strcat(tempvar.tempstring,tempvar.temprow1);
    *tempvar.temprow1=0;
    if(nh->i.child!=FAIL)
      sprintf(tempvar.temprow1,"%d ",nh->i.child+1);
    else
      strcpy(tempvar.temprow1,"");
    strcat(tempvar.tempstring,tempvar.temprow1);
    *tempvar.temprow1=0;
    if(nh->i.prev!=FAIL)
      sprintf(tempvar.temprow1,"%d ",nh->i.prev+1);
    else
      strcpy(tempvar.temprow1,"");
    strcat(tempvar.tempstring,tempvar.temprow1);
    *tempvar.temprow1=0;
    if(nh->i.next!=FAIL)
      sprintf(tempvar.temprow1,"%d ",nh->i.next+1);
    else
      strcpy(tempvar.temprow1,"");
    strcat(tempvar.tempstring,tempvar.temprow1);
    *tempvar.temprow1=0;
    str2ted(read_win.text->dialog,MSGTOP_LINKS,tempvar.tempstring);
  }
  sprintf(tempvar.tempstring,"%5d",active.msg_num+1);
  str2ted(read_win.text->dialog,MSGTOP_MSGNUM,tempvar.tempstring);
  strcpy(tempvar.tempstring,"");
  
  if(nh->flags.header_only)
    strcat(tempvar.tempstring,MSG_FLAG_HEAD);
  if(nh->flags.requested)
    strcat(tempvar.tempstring,MSG_FLAG_REQ);
  if(nh->flags.outgoing)
    strcat(tempvar.tempstring,MSG_FLAG_OUT);
  if(nh->flags.replied)
    strcat(tempvar.tempstring,MSG_FLAG_REP);
  if(nh->flags.deleted)
    strcat(tempvar.tempstring,MSG_FLAG_DEL);
  if(nh->flags.keep)
    strcat(tempvar.tempstring,MSG_FLAG_KEEP);
  str2ted(read_win.text->dialog,MSGTOP_FLAGS,tempvar.tempstring);
  str2ted(read_win.text->dialog,MSGTOP_SUBJ,nh->subject);
  str2ted(read_win.text->dialog,MSGTOP_FROM,nh->from);
  sprintf(tempvar.tempstring,"%04d%02d%02d%02d%02d",nh->datetime.year+1980,nh->datetime.month+1,nh->datetime.day,
                                                    nh->datetime.hour,nh->datetime.min);
  str2ted(read_win.text->dialog,MSGTOP_DATETIME,tempvar.tempstring);                                                    
  Return;
}

