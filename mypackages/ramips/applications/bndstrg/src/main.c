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
    	main.c
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>

#include "bndstrg.h"

int DebugLevel = DEBUG_ERROR;

extern struct bndstrg_event_ops bndstrg_event_ops;

extern char BndStrgRssiDiff_s, BndStrgRssiLow_s;
extern u32 BndStrgAge_s, BndStrgHoldTime_s, BndStrgCheckTime_s;

static void usage()
{

	printf("-d <bndstrg debug level> 0..4\n");
	printf("-l <bndstrg RssiLow> default -88\n");
	printf("-D <bndstrg RssiDiff> default 15\n");
	printf("-a <bndstrg Age Time> :ms\n");
	printf("-H <bndstrg Hold Time> :ms\n");
	printf("-c <bndstrg Check Time> :ms\n");
}

static void process_options(int argc, char *argv[])
{
	int c;
	int debug = DEBUG_ERROR;

	while ((c = getopt(argc, argv, "hd:l:D:a:H:c:")) != -1) {
		switch (c) {
		    case 'd':
				debug = atoi(optarg);
				if (debug >= 0 && debug <= DEBUG_INFO) {
					DebugLevel = debug;
				} else {
					printf("-d option does not have this debug_level %d, must be 0..4 range.\n", debug);
					usage();
					exit(0);
				}
				break;
			case 'l':
				BndStrgRssiLow_s = atoi(optarg);
				if (BndStrgRssiLow_s > 0 || BndStrgRssiLow_s < -100){
					printf("-l option does not have %d, must be (-100 .. 0) range.\n", BndStrgRssiLow_s);
					usage();
					exit(0);
				}
				break;
			case 'D':
				BndStrgRssiDiff_s = atoi(optarg);
				break;
			case 'a':
				BndStrgAge_s = atoi(optarg);
				break;
			case 'H':
				BndStrgHoldTime_s = atoi(optarg);
				break;
			case 'c':
				BndStrgCheckTime_s = atoi(optarg);
				break;		
		    case 'h':
				usage();
				exit(0);
		    default:
				usage();
				exit(0);
		}
	}
}

int main(int argc, char *argv[])
{

	struct bndstrg bndstrg;
	pid_t child_pid;

#ifdef SYSLOG
	openlog("bndstrg", LOG_PID|LOG_NDELAY, LOG_DAEMON);
#endif

	/* options processing */
	process_options(argc, argv);

	child_pid = fork();

	if (child_pid == 0) {
		int ret = 0;
		DBGPRINT(DEBUG_OFF, "Initialize bndstrg\n");
		ret = bndstrg_init(&bndstrg, &bndstrg_event_ops, 0, 0, 2);

		if (ret)
			goto error;

		bndstrg_run(&bndstrg);

	} else
		goto error;
#if 0
error0:
	bndstrg_deinit(&hs);
#endif
error:
	return -1;
}
