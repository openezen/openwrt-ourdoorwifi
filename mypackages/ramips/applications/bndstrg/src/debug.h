/*
 ***************************************************************************
 * MediaTek Inc. 
 *
 * All rights reserved. source code is an unpublished work and the
 * use of a copyright notice does not imply otherwise. This source code
 * contains confidential trade secret material of MediaTek. Any attemp
 * or participation in deciphering, decoding, reverse engineering or in any
 * way altering the source code is stricitly prohibited, unless the prior
 * written consent of MediaTek, Inc. is obtained.
 ***************************************************************************

    Module Name:
    	debug.h
*/

#ifndef __DEBUG_H__
#define __DEBUG_H__

#define DEBUG_OFF		0
#define DEBUG_ERROR		1
#define DEBUG_WARN		2
#define DEBUG_TRACE		3
#define DEBUG_INFO		4

extern int DebugLevel;

#ifdef SYSLOG
#include<syslog.h>
#define DBGPRINT(Level, fmt, args...) 	\
{                                   	\
    if (Level <= DebugLevel)      \
    {                               \
	syslog(LOG_WARNING, fmt, ## args); \
    }                               \
}
#else
#define DBGPRINT(Level, fmt, args...)   \
{                                       \
	if (Level <= DebugLevel)          \
	{                                   \
		printf("[%s]", __FUNCTION__);	\
		printf( fmt, ## args);          \
	}                                   \
}
#endif

#ifdef SYSLOG
#define RED(_text) _text
#define GRN(_text) _text
#define YLW(_text) _text
#define BLUE(_text) _text
#else
#define RED(_text)  "\033[1;31m"_text"\033[0m"
#define GRN(_text)  "\033[1;32m"_text"\033[0m"
#define YLW(_text)  "\033[1;33m"_text"\033[0m"
#define BLUE(_text) "\033[1;36m"_text"\033[0m"
#endif

#ifdef BND_STRG_DBG
#define BND_STRG_DBGPRINT(Level, fmt, args...) \
{                                       	\
	DBGPRINT(Level, fmt, ## args);          \
}

#else /* BND_STRG_DBG */
#define BND_STRG_DBGPRINT(Level, fmt, args...)
#endif /* !BND_STRG_DBG */

#ifdef BND_STRG_QA
#define BND_STRG_PRINTQAMSG(_table, _entry, fmt, args...) \
{	\
	if (MAC_ADDR_EQUAL(_table->MonitorAddr, _entry->Addr)) {	\
		DBGPRINT(DEBUG_OFF, fmt, ## args); \
	} else { \
		DBGPRINT(DEBUG_TRACE, fmt, ## args); \
	} \
}
#else  /* BND_STRG_QA */
#define BND_STRG_PRINTQAMSG(_Level, _Fmt)
#endif /* BND_STRG_QA */
#endif /* __DEBUG_H__ */
