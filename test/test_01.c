#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

#define NUM_PROCESSES 8
#define NUM_ITERATIONS 1000000

void perform_task() {
	volatile int sum = 0;

	for (int i = 0; i < NUM_ITERATIONS; ++i) {
		sum += i;
	}
}

int main() {
	pid_t pid;
	for (int i = 0; i < NUM_PROCESSES; ++i) {
		pid = fork();
		if (pid == 0) {
			perform_task();
			exit(0);
		}
	} while(wait(NULL) > 0); // 等待子进程结束

	return 0;
}
