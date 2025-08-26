#include <stdio.h>
#include <stdlib.h>

#define SIZE 1024*1024*128  // 128M

void memory_heavy_task() {
	/*
	 * 128M * 4B = 512MB
	 * 512MB / 4KB = 128K
	 * 512MB / 16KB = 32K
	 */

	int *arr = (int *)malloc(SIZE * sizeof(int));
	if (!arr) {
		printf("Memory allocation failed!\n");
		return;
	}

	/* WRITE */
	for (int i = 0; i < SIZE; i++) {
		arr[i] = i;
	}

	/* READ */
	for (int i = 0; i < SIZE; i++) {
		if (arr[i] != i)
			printf("%d", i);
	}
	free(arr);
}
 
int main() {
	memory_heavy_task();
	return 0;
}
