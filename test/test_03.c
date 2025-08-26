#include <stdio.h>
#include <stdlib.h>

#define SIZE 1024*1024*128  // 128M

void frequent_page_faults() {
	int *arr = (int *)malloc(SIZE * sizeof(int)); // 128M * 4B = 512MB
	if (!arr) {
		printf("Memory allocation failed!\n");
		return;
	}
			    
	/* WRITE */
	for (int i = 0; i < SIZE; i += 128) { // 128 * 4B = 512B
		arr[i] = i;
	}

	/* READ */
	for (int i = 0; i < SIZE; i += 128) {
		if (arr[i] != i)
			printf("%d\n", i);
	}
			    
	free(arr);
}
			    
int main() {
	frequent_page_faults();
	return 0;
}
