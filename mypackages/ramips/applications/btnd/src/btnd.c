#include <fcntl.h>
#include <signal.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <string.h>
#include "ralink_gpio.h"


static char * btnname = NULL;
static int btnpin = -1;

#if 0
#define DBG(...) fprintf(stderr, "<btnd> %s(),L%d: ", __FUNCTION__, __LINE__);printf(__VA_ARGS__)
#else
#define DBG(...)
#endif

static void hook_gpio(int pin)
{
    int fd;
    ralink_gpio_reg_info info;

    DBG("\n");
    fd = open("/dev/gpio", O_RDONLY);
    if (fd < 0)
    {
        perror("/dev/gpio");
        return;
    }
    /* set gpio direction to input */
    if (ioctl(fd, RALINK_GPIO_SET_DIR_IN, RALINK_GPIO(pin)) < 0)
        goto ioctl_err;
    /* enable gpio interrupt */
    if (ioctl(fd, RALINK_GPIO_ENABLE_INTP) < 0)
        goto ioctl_err;
    /* register my information */
    info.pid = getpid();
    info.irq = pin;
    DBG("thread: pid=%d,irq=%d\n",info.pid,info.irq);
    if (ioctl(fd, RALINK_GPIO_REG_IRQ, &info) < 0)
        goto ioctl_err;
    close(fd);

    return;

ioctl_err:
    perror("ioctl");
    close(fd);
    return;
}


static void signal_handler(int signum)
{
    char cmdstr[256] = {0};
    DBG("\n");
    if (signum == SIGUSR1)
    {
        snprintf(cmdstr, sizeof(cmdstr), "sh /etc/btnd/%s_click.sh > /dev/ttyS1", btnname);
        DBG("%s\n", cmdstr);
        system(cmdstr);
    }
    else if(signum == SIGUSR2)
    {
        snprintf(cmdstr, sizeof(cmdstr), "sh /etc/btnd/%s_hold.sh > /dev/ttyS1", btnname);
        DBG("%s\n", cmdstr);
        system(cmdstr);
    }
    else
    {
        DBG("%s(%d), signal %d not registered.\n", __FUNCTION__, signum, signum);
    }
    return;
}



int main(int argc, char** argv)
{
	int fd;
	pid_t fpid;

	DBG("\n");
        /*modified by zhangyang ,20150723,for creating a same process*/
	fpid=fork();


	if (fpid < 0)
	{
		printf("error in fork!");
	}
	else if (fpid == 0)
	{
		printf("i am the child process, my process id is %d\n",getpid()); 
		if (argc < 3)
		{
			printf("usage: btnd <name> <pin>\nexample: btnd wps 2\n");
			exit(-1);
		}

		btnname = argv[1];
		btnpin = atoi(argv[2]);

		if (!btnname || btnpin<0)
		{
			printf("invalid argument!\n");
			printf("usage: btnd <name> <pin>\nexample: btnd wps 2\n");
			exit(-1);
		}

		fd = open("/dev/gpio", O_RDONLY);
		if (fd < 0)
		{
			system("mknod /dev/gpio c 252 0");
			printf("btnd module can't open /dev/gpio,so mknode dev/gpio c 252 0\n");
		}


		hook_gpio(btnpin);
		signal(SIGUSR1, signal_handler);
		signal(SIGUSR2, signal_handler);
		while(1) sleep(500); /* daemon */
  
	}
	else
	{
		printf("i am the parent process, my process id is %d/n",getpid());
		exit(0);
	}
}
