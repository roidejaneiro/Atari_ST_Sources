#include "firenews.h"
/********************************************************************/
/********************************************************************/
void init_flags_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"init_setdelflag_win(void)\n");
Log(LOG_INIT,"Set/Del Flags Window Init\n");
#endif
  rsrc_gaddr(R_TREE,SETDEL_FLAGS,&flags_win.dialog);
  strncpy(flags_win.w_name,alerts[WN_SETFLAGS],MAXWINSTRING);
  flags_win.attr=NAME|MOVE|CLOSE;
  flags_win.icondata=&icons[ICON_FIRESTORM];
  flags_win.i_x=100;
  flags_win.i_y=100;
  flags_win.status=WINDOW_CLOSED;
  flags_win.type=TYPE_DIALOG;
  form_center(flags_win.dialog, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter);
  Return;
}

/********************************************************************/
/********************************************************************/
void open_flags_win(int state)
{
  flags_win.tag=state;
  if ( flags_win.tag == FLAGS_SET )
  {
    strncpy( flags_win.w_name , alerts[ WN_SETFLAGS ] , MAXWINSTRING);
    button(&flags_win,FLAG_TEXT_FROM,CLEAR_FLAGS,HIDETREE,FALSE);
    button(&flags_win,FLAG_FROM,CLEAR_FLAGS,HIDETREE,FALSE);
    button(&flags_win,FLAG_TEXT_TO,CLEAR_FLAGS,HIDETREE,FALSE);
    button(&flags_win,FLAG_TO,CLEAR_FLAGS,HIDETREE,FALSE);
  }
  else if ( flags_win.tag == FLAGS_DEL )
  {
    strncpy( flags_win.w_name , alerts[ WN_DELFLAGS ] , MAXWINSTRING );
    button(&flags_win,FLAG_TEXT_FROM,CLEAR_FLAGS,HIDETREE,FALSE);
    button(&flags_win,FLAG_FROM,CLEAR_FLAGS,HIDETREE,FALSE);
    button(&flags_win,FLAG_TEXT_TO,CLEAR_FLAGS,HIDETREE,FALSE);
    button(&flags_win,FLAG_TO,CLEAR_FLAGS,HIDETREE,FALSE);
  }
  else if ( ( flags_win.tag == FLAGS_SETDEL_LIST ) || ( flags_win.tag == FLAGS_SETDEL_READ ) )
  {
    strncpy( flags_win.w_name , alerts[ WN_SETDELFLAGS ] , MAXWINSTRING );
    button(&flags_win,FLAG_TEXT_FROM,SET_FLAGS,HIDETREE,FALSE);
    button(&flags_win,FLAG_FROM,SET_FLAGS,HIDETREE,FALSE);
    button(&flags_win,FLAG_TEXT_TO,SET_FLAGS,HIDETREE,FALSE);
    button(&flags_win,FLAG_TO,SET_FLAGS,HIDETREE,FALSE);
    if ( flags_win.tag == FLAGS_SETDEL_READ )
      active.tempmessage=get_entity(active.mlist,active.msg_num);
    else
      active.tempmessage=get_entity(active.mlist,list2msg(msglist_win.text->select));

    if(active.tempmessage->flags.header_only)
      button(&flags_win,FLAG_HEADERONLY,SET_STATE,SELECTED,FALSE);
    else
      button(&flags_win,FLAG_HEADERONLY,CLEAR_STATE,SELECTED,FALSE);
    if(active.tempmessage->flags.requested)
      button(&flags_win,FLAG_REQUESTED,SET_STATE,SELECTED,FALSE);
    else
      button(&flags_win,FLAG_REQUESTED,CLEAR_STATE,SELECTED,FALSE);
    if(active.tempmessage->flags.outgoing)
      button(&flags_win,FLAG_OUTGOING,SET_STATE,SELECTED,FALSE);
    else
      button(&flags_win,FLAG_OUTGOING,CLEAR_STATE,SELECTED,FALSE);
    if(active.tempmessage->flags.replied)
      button(&flags_win,FLAG_REPLIED,SET_STATE,SELECTED,FALSE);
    else
      button(&flags_win,FLAG_REPLIED,CLEAR_STATE,SELECTED,FALSE);
    if(active.tempmessage->flags.deleted)
      button(&flags_win,FLAG_DELETED,SET_STATE,SELECTED,FALSE);
    else
      button(&flags_win,FLAG_DELETED,CLEAR_STATE,SELECTED,FALSE);
    if(active.tempmessage->flags.keep)
      button(&flags_win,FLAG_KEEP,SET_STATE,SELECTED,FALSE);
    else
      button(&flags_win,FLAG_KEEP,CLEAR_STATE,SELECTED,FALSE);
  }
  open_nonmodal( &flags_win , NULL );  
}

/********************************************************************/
/********************************************************************/
void check_flags_win(const RESULT svar)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"check_setdelflags_win(...)\n");
#endif
  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_dialog(&flags_win);
  }
  else if(svar.type==DIALOG_CLICKED)
  {
    switch(svar.data[SVAR_OBJECT])
    {
      case FLAG_OK:
      {
        int counter;
        char flags[NUM_FLAG+1];
        strcpy(flags,"");
        if (flags_win.dialog[FLAG_OUTGOING].ob_state&SELECTED)
          strcat(flags,MSG_FLAG_OUT);
        if (flags_win.dialog[FLAG_NEW].ob_state&SELECTED)
          strcat(flags,MSG_FLAG_NEW);
        if (flags_win.dialog[FLAG_HEADERONLY].ob_state&SELECTED)
          strcat(flags,MSG_FLAG_HEAD);
        if (flags_win.dialog[FLAG_REQUESTED].ob_state&SELECTED)
          strcat(flags,MSG_FLAG_REQ);
        if (flags_win.dialog[FLAG_DELETED].ob_state&SELECTED)
          strcat(flags,MSG_FLAG_DEL);
        if (flags_win.dialog[FLAG_REPLIED].ob_state&SELECTED)
          strcat(flags,MSG_FLAG_REP);
        if (flags_win.dialog[FLAG_KEEP].ob_state&SELECTED)
          strcat(flags,MSG_FLAG_KEEP);
        
        graf_mouse(BUSYBEE,NULL);
        if ( ( flags_win.tag == FLAGS_SET ) || ( flags_win.tag == FLAGS_DEL ) )
        {
          for(counter=ted2int(flags_win.dialog,FLAG_FROM)-1 ; (counter<=ted2int(flags_win.dialog,FLAG_TO)-1)&&(ted2int(flags_win.dialog,FLAG_FROM)>0); counter++)
          {
            if(flags_win.tag==FLAGS_SET)
              change_flag(counter,flags,TRUE);
            else if(flags_win.tag==FLAGS_DEL)
              change_flag(counter,flags,FALSE);
          }
        }
        else if ( (flags_win.tag == FLAGS_SETDEL_LIST ) || ( flags_win.tag == FLAGS_SETDEL_READ ) )
        {
          char cflags[NUM_FLAG+1];
          strcpy(cflags,"");
          if (!(flags_win.dialog[FLAG_OUTGOING].ob_state&SELECTED))
            strcat(cflags,MSG_FLAG_OUT);
          if (!(flags_win.dialog[FLAG_NEW].ob_state&SELECTED))
            strcat(cflags,MSG_FLAG_NEW);
          if (!(flags_win.dialog[FLAG_HEADERONLY].ob_state&SELECTED))
            strcat(cflags,MSG_FLAG_HEAD);
          if (!(flags_win.dialog[FLAG_REQUESTED].ob_state&SELECTED))
            strcat(cflags,MSG_FLAG_REQ);
          if (!(flags_win.dialog[FLAG_DELETED].ob_state&SELECTED))
            strcat(cflags,MSG_FLAG_DEL);
          if (!(flags_win.dialog[FLAG_REPLIED].ob_state&SELECTED))
            strcat(cflags,MSG_FLAG_REP);
          if (!(flags_win.dialog[FLAG_KEEP].ob_state&SELECTED))
            strcat(cflags,MSG_FLAG_KEEP);
          if( flags_win.tag == FLAGS_SETDEL_LIST )
          {
            change_flag(msglist_win.text->select,flags,TRUE);
            change_flag(msglist_win.text->select,cflags,FALSE);
          }
          else
          {
            change_flag(active.msg_num,flags,TRUE);
            change_flag(active.msg_num,cflags,FALSE);
          }
        }
        graf_mouse(ARROW,NULL);
        close_dialog(&flags_win);
        if(msglist_win.status!=WINDOW_CLOSED)
          redraw_window(&msglist_win);
        if(read_win.status!=WINDOW_CLOSED)
          top_of_document();
        button(&flags_win,FLAG_OK,CLEAR_STATE,SELECTED,TRUE);
        break;
      }
      case FLAG_CANCEL:
      {
        close_dialog(&flags_win);
        button(&flags_win,FLAG_CANCEL,CLEAR_STATE,SELECTED,TRUE);
        break;
      }
      default:
      {
        break;
      }
    }
  }
}

/********************************************************************/
/* �ndrar en flagga i ett brev                                      */
/********************************************************************/
int change_flag(const int msg_num, const char *flag, const int on)
{
  FILE *hdr=NOLL;
  NewsHeader *h;
  
#ifdef LOGGING
Log(LOG_FUNCTION,"change_flag(...)\n");
Log(LOG_FILEOP,"Changeing Flag in MSG-file routine: Started\n");
#endif
  active.tempgroup=get_entity(active.glist,active.group_num);
  if (!active.tempgroup)
  {
    #ifdef LOGGING
    Log(LOG_ERROR,"Could not get group-information\n");
    #endif
    Return FALSE;
  }
  sprintf(tempvar.tempstring,"%s%s%s",config.newsdir,active.tempgroup->filename,HEADEREXT);
  hdr=fopen(tempvar.tempstring,"rb+");
  if(!hdr)
  {
    #ifdef LOGGING
    Log(LOG_ERROR,"Could not open Headerfile\n");
    #endif
    Return FALSE;
  }
  h=get_entity(active.mlist,msg_num);
  if(!h)
  {
    #ifdef LOGGING
    Log(LOG_ERROR,"Could not get message-info\n");
    #endif
    fclose(hdr);
    Return FALSE;
  }
  fseek(hdr,SIZE_ID+msg_num*sizeof(NewsHeader),SEEK_SET);
  
  if(strstr(flag,MSG_FLAG_OUT))
    h->flags.outgoing=on;
  if(strstr(flag,MSG_FLAG_REQ))
    h->flags.requested=on;
  if(strstr(flag,MSG_FLAG_REP))
    h->flags.replied=on;
  if(strstr(flag,MSG_FLAG_HEAD))
    h->flags.header_only=on;
  if(strstr(flag,MSG_FLAG_DEL))
    h->flags.deleted=on;
  if(strstr(flag,MSG_FLAG_KEEP))
    h->flags.keep=on;
  if(strstr(flag,MSG_FLAG_NEW))
    h->flags.new=on;
  if(strstr(flag,MSG_FLAG_TOUCHED))
    h->flags.touched=on;
  if(fwrite(h,sizeof(NewsHeader),1,hdr)!=1)
  {
    #ifdef LOGGING
    Log(LOG_ERROR,"Could not write changes to headerfile\n");
    #endif
    fclose(hdr);
    Return FALSE;
  }
  fclose(hdr);
  Return TRUE;
}