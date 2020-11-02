#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <linux/if.h>
#include <linux/mii.h>
#include <linux/types.h>

//#include <linux/autoconf.h>
#include "ra_ioctl.h"

void show_usage(void)
{
#ifndef CONFIG_RT2860V2_AP_MEMORY_OPTIMIZATION
	printf("mii_mgr -g -p [phy number] -r [register number]\n");
	printf("  Get: mii_mgr -g -p 3 -r 4\n\n");
	printf
	    ("mii_mgr -s -p [phy number] -r [register number] -v [0xvalue]\n");
	printf("  Set: mii_mgr -s -p 4 -r 1 -v 0xff11\n\n");
#endif
}

int main(int argc, char *argv[])
{
	int sk, opt, ret;
	char options[] = "gsp:n:r:v:?t";
	int method;
	struct ifreq ifr;
	ra_mii_ioctl_data mii;
#if defined (CONFIG_RALINK_MT7620)
	struct rt3052_esw_reg reg;
#endif
    int link_flags = 0;

	if (argc < 2) {
		show_usage();
		return 0;
	}

	sk = socket(AF_INET, SOCK_DGRAM, 0);
	if (sk < 0) {
		printf("Open socket failed\n");
		return -1;
	}

#if defined (CONFIG_RALINK_MT7620) && !defined (CONFIG_TARGET_ramips_mt7620) 
	strncpy(ifr.ifr_name, "eth2", 5);
#else
	strncpy(ifr.ifr_name, "eth0", 5);
#endif
	ifr.ifr_data = &mii;

	while ((opt = getopt(argc, argv, options)) != -1) {
		switch (opt) {
		case 'g':
			method = RAETH_MII_READ;
			break;
		case 's':
			method = RAETH_MII_WRITE;
			break;
		case 'p':
			mii.phy_id = strtoul(optarg, NULL, 10);
			break;
		case 'r':
#if defined (CONFIG_RALINK_MT7621)
			if (mii.phy_id == 31) {
				mii.reg_num = strtol(optarg, NULL, 16);
			} else {
				mii.reg_num = strtol(optarg, NULL, 10);
			}
#else
			mii.reg_num = strtol(optarg, NULL, 10);
#endif
			break;
        case 'n':
#if defined (CONFIG_RALINK_MT7621)
			method = RAETH_MII_READ;
            mii.phy_id = 31;
            int val = strtoul(optarg, NULL, 10);
            if (val >= 0 && val <= 4) {
                mii.reg_num = val * 0x100 + 0x3008;
            } else {
                mii.reg_num = 0x3008;
            }
            link_flags = 1;
#elif defined(CONFIG_RALINK_MT7620)
			ifr.ifr_data = &reg;
			method = RAETH_ESW_REG_READ;
            int val = strtoul(optarg, NULL, 10);
            if (val >= 0 && val <= 4) {
                reg.off = val * 0x100 + 0x3008;
            } else {
                reg.off = 0x3008;
            }
            link_flags = 1;
#elif defined (CONFIG_RALINK_MT7628)
			method = RAETH_MII_READ;
			int val = strtoul(optarg, NULL, 10);
			mii.phy_id = val;			
			mii.reg_num = 1;			
			link_flags = 1;
#endif
            break;
		case 'v':
			mii.val_in = strtol(optarg, NULL, 16);
			break;
		case '?':
			show_usage();
			break;
		}
	}

	ret = ioctl(sk, method, &ifr);
	if (ret < 0) {
		printf("mii_mgr: ioctl error\n");
	} else {
		switch (method) {
		case RAETH_MII_READ:
            if (link_flags) {
#if defined (CONFIG_RALINK_MT7621)				
                printf("%s\n", mii.val_out & 0x1 ? "is_up": "is_down");
#elif defined (CONFIG_RALINK_MT7628)
				printf("%s\n", mii.val_out & 0x4 ? "is_up": "is_down");
#endif
            } else {
			    printf("Get: phy[%d].reg[%d] = %04x\n",
                        mii.phy_id, mii.reg_num, mii.val_out);
            }
			break;
#if defined(CONFIG_RALINK_MT7620)
		case RAETH_ESW_REG_READ:
            if (link_flags) {
                printf("%s\n", reg.val & 0x1 ? "is_up": "is_down");
            } else {
			    printf("Get: reg[%d] = %04x\n", reg.off, reg.val);
			}
			break;
#endif
		case RAETH_MII_WRITE:
			printf("Set: phy[%d].reg[%d] = %04x\n",
			       mii.phy_id, mii.reg_num, mii.val_in);
			break;
		}
    }
	close(sk);
	return ret;
}
