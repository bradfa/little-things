#ifndef _GNU_SOURCE
# define _GNU_SOURCE
#endif

#include <stdio.h>
#include <string.h>

int main()
{
	char buf[128];
	printf("First of a given error is _GNU_SOURCE strerror_r(), second is POSIX strerror_l()\n");
	printf("Erorr 1: %s\n", strerror_r(1, buf, sizeof(buf)));
	printf("Error 1: %s\n", strerror_l(1, NULL));
	printf("Erorr 2: %s\n", strerror_r(2, buf, sizeof(buf)));
	printf("Error 2: %s\n", strerror_l(2, NULL));
	printf("Erorr 3: %s\n", strerror_r(3, buf, sizeof(buf)));
	printf("Error 3: %s\n", strerror_l(3, NULL));
	printf("Erorr 4: %s\n", strerror_r(4, buf, sizeof(buf)));
	printf("Error 4: %s\n", strerror_l(4, NULL));
	printf("Erorr 5: %s\n", strerror_r(5, buf, sizeof(buf)));
	printf("Error 5: %s\n", strerror_l(5, NULL));
	printf("Erorr 9: %s\n", strerror_r(9, buf, sizeof(buf)));
	printf("Error 9: %s\n", strerror_l(9, NULL));
	return 0;
}
