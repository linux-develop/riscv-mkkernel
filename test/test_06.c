#include <stdio.h>
#include <stdlib.h>

#define NUM_ALLOCATIONS 1000
#define BLOCK_SIZE 512

void memory_fragmentation_test() {
	void *blocks[NUM_ALLOCATIONS];

	for (int i = 0; i < NUM_ALLOCATIONS; ++i) {
		blocks[i] = malloc(BLOCK_SIZE);
		if (!blocks[i]) {
			printf("Memory allocation failed\n");
			return;
		}
	}
	
	for (int i = 0; i < NUM_ALLOCATIONS; i+=2) {
		free(blocks[i]);
	}
	
	for (int i = 0; i < NUM_ALLOCATIONS; i+=2) {
		blocks[i] = malloc(BLOCK_SIZE);
		if (!blocks[i]) {
			printf("Memory allocation failed\n");
			return;
		}
	}
	
	for (int i = 0; i < NUM_ALLOCATIONS; ++i) {
		free(blocks[i]);
	}
}

int main() {
	memory_fragmentation_test();
	return 0;
}
