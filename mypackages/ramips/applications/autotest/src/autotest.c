/**************************************************************************
 * siwifi Tech Inc.
 *
 * (c) Copyright, siwifi Technology, Inc.
 ****************************************************************************/

#include <stdio.h>             
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <linux/autoconf.h>
#include <getopt.h>

void show_usage(void)
{
	printf("-s Autotest start auto reboot test\n");
	printf("-a Autotest abort auto reboot test\n");
	printf("-t Autotest show kernel runtime : freetime\n");
	printf("-p Autotest ping baidu (0:ping fail 1:ping ok)\n");
	printf("-d Autotest detect wan prop type(0:no capile 1:pppoe 2:dhcp 3:static ip)\n");
	printf("-w Autotest turn off/on 2.4G and 5G \n");
	printf("-l Autotest turn on/off all leds\n");
	printf("-l Autotest reset jffs2 filesystem\n");
	printf("-r Autotest reboot rounter\n");
}

void autotest_startauto(void)
{
	printf("\nAutotest will start auto reboot test 10 seconds later!!\n");

	if((access( "/etc/autotest/autotest", 0 )) != -1)
		system("cp /etc/autotest/autotest /etc/init.d/autotest > /dev/ttyS1");
	else
	{
		printf("\nAutotest startauto no /etc/autotest/autotest\n");
		return ;
	}
	if((access( "/etc/init.d/autotest", 0 )) != -1)
	{
		system("chmod -R 777 /etc/init.d/autotest > /dev/ttyS1");
		system("/etc/init.d/autotest enable > /dev/ttyS1");
	}
	else
	{
		printf("\nAutotest startauto no /etc/init.d/autotest\n");
		return;
	}

	sleep(10);
	system("reboot > /dev/ttyS1");
}

void autotest_abortauto(void)
{
	printf("\nAutotest will abort auto reboot test after reboot!!\n");

	if((access( "/etc/init.d/autotest", 0 )) != -1)
	{

		system("rm -f /etc/init.d/autotest > /dev/ttyS1");
	}
	else
	{
		printf("\nAutotest abortauto no /etc/init.d/autotest\n");
		return ;
	}

	if((access( "etc/rc.d/S124autotest", 0 )) != -1)
	{

		system("rm -f /etc/rc.d/S124autotest > /dev/ttyS1");
	}
	else
	{
		printf("\nAutotest abortauto no /etc/rc.d/S124autotest\n");
		return ;
	}
}

void autotest_showtime(void)
{
	//get kerne runing time
	printf("\nAutotest show kernel time,then sleep 20 senconds\n");
	printf("runtime : freetime\n");
	system("cat /proc/uptime > /dev/ttyS1");
	sleep(20);
}

void autotest_wantyep(void)
{
	if((access( "/etc/config/network", 0 )) != -1)
	{
		printf("\nAutotest test wan prop type(0:no capile 1:pppoe 2:dhcp 3:static ip)\n");
    		system("ubus call network.internet wantype > /dev/ttyS1");
	}
	else
		printf("\nAutotest wantyep no /etc/config/network\n");
}

void autotest_pingbaidu(void)
{
	printf("\nAutotest ping baidu (0:ping fail 1:ping ok)\n");
	if((access( "/etc/config/network", 0 )) != -1)
    	system("ubus call network.internet pingbaidu > /dev/ttyS1");
}

void autotest_switchwifi(void)
{
	if((access( "/etc/config/wireless", 0 )) != -1)
	{
		printf("\nAutotest turn off 2.4G,then sleep 14 seconds \n");
		system("uci set wireless.@wifi-device[0].disabled=1 > /dev/ttyS1");
		system("wifi > /dev/ttyS1");
		system("uci commit > /dev/ttyS1");
		sleep(14);

		printf("Autotest turn on 2.4G,then sleep 4 seconds\n");
		system("uci set wireless.@wifi-device[0].disabled=0 > /dev/ttyS1");
		system("wifi > /dev/ttyS1");
		system("uci commit > /dev/ttyS1");
		sleep(14);

		printf("Autotest turn off 5G,then sleep 4 seconds\n");
		system("uci set wireless.@wifi-device[1].disabled=1 > /dev/ttyS1");
		system("wifi > /dev/ttyS1");
		system("uci commit > /dev/ttyS1");
		sleep(14);

		printf("Autotest turn on 5G,then sleep 4 seconds\n");
		system("uci set wireless.@wifi-device[1].disabled=0 > /dev/ttyS1");
		system("wifi > /dev/ttyS1");
		system("uci commit > /dev/ttyS1");
		sleep(14);
	}
	else
		printf("\nAutotest switchwifi no /etc/config/wireless\n");
}

void autotest_switchled(void)
{
	printf("\nAutotest turn on all leds,then sleep 2 sconds\n");
	if((access( "/etc/init.d/led", 0 )) != -1)
	{
		system("uci set system.led_system.trigger=default-on");
		system("uci set system.led_internet.trigger=default-on");
		system("uci set system.led_wifi_led.trigger=default-on");
		system("uci set system.led_wifi5g.trigger=default-on");
		system("/etc/init.d/led restart /dev/ttyS1");
		sleep(2);

		printf("Autotest turn of all leds \n");
		system("uci set system.led_system.trigger=none");
		system("uci set system.led_internet.trigger=none");
		system("uci set system.led_wifi_led.trigger=none");
		system("uci set system.led_wifi5g.trigger=none");
		system("/etc/init.d/led restart > /dev/ttyS1");
	}
	else
		printf("\nAutotest switchled no /etc/config/led\n");
}

void autotest_resetjffs2(void)
{
	printf("\nAutotest reset jffs2 now!! \n");
	system("jffs2reset -y > /dev/ttyS1");
}

void autotest_reboot(void)
{
        printf("\nAutotest reboot now!! \n");
        system("reboot > /dev/ttyS1");
}

int main(int argc, char *argv[])
{
	int ch, time = 0, ping = 0,prop = 0,wifi = 0, abortauto =0;
	int led = 0,jffs2 = 0,reboot = 0, startauto = 0;

	int opt;
	char options[] = "tdpwljrsa";
	int s_fd;
	int ttyfd;  
	int n_fd;

	pid_t fpid;

	ttyfd = open("/dev/ttyS1",(O_RDWR), 0644);
	if (ttyfd < 0)
	{
		printf("open /dev/ttyS1 error!!\n");
		//exit(-1);
	}

	s_fd = dup(STDOUT_FILENO);
	if (s_fd < 0)
	{
		printf("dup STDOUT_FILENO erroor!!\n");
	}

	fflush(stdout);
	setvbuf(stdout,NULL,_IONBF,0);

	n_fd = dup2(ttyfd, STDOUT_FILENO);
	if (n_fd < 0)
	{
		printf("dup2 ttyS1 replace STDOUT_FILENO error!!!\n");
	}
	
	if (argc < 2)
	{
		show_usage();
		exit(-1);
	}


	while ((opt = getopt (argc, argv, options)) != -1)
	{
		switch (opt)
		{
			case 't':
				time = 1;
				break;
			case 'd':
				prop = 1;
				break;
			case 'p':
				ping = 1;
				break;
			case 'w':
				wifi = 1;
				break;
			case 'l':
				led = 1;
				break;
			case 'j':
				jffs2 = 1;
				break;
			case 'r':
				reboot = 1;
				break;
			case 's':
				startauto = 1;
				break;
			case 'a':
				abortauto = 1;
				break;
			case '?':
				show_usage();
				break;
		}
	}

	fpid=fork();


	if (fpid < 0)
	{
		printf("error in fork! \n");
		exit(-1);
	}
	else if (fpid == 0)
	{
		printf("Autotest son process, process id is %d\n",getpid());
		printf("Autotest result Start !!!!!!\n");
		printf("Autotest startauto:%d abortauto:%d time:%d prop:%d ping:%d wifi:%d led:%d jffs2:%d reboot:%d\n",
				startauto,abortauto,time,prop,ping,wifi,led,jffs2,reboot);

		if(startauto)
		{
			autotest_startauto();
		}

		if(abortauto)
		{
			autotest_abortauto();
		}

		if(time)
		{
			autotest_showtime();
		}

		if(prop)
		{
			autotest_wantyep();
		}

		if(ping)
		{
			autotest_pingbaidu();
		}

		if(wifi)
		{
			autotest_switchwifi();
		}

		if(led)
		{
			autotest_switchled();
		}

		if(jffs2)
		{
			autotest_resetjffs2();
		}

		if(reboot)
		{
			autotest_reboot();
		}

		printf("Autotest result End !!!!!!\n");
		
		if (dup2(s_fd, n_fd) < 0)
		{
                	printf("dup2 resume STDOUT_FILENO error!!!\n");
		}
		exit(0);
	}
	else
	{
		printf("Autotest parent process,process id is %d \n",getpid());
		exit(0);
	}
}

