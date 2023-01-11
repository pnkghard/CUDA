#include<stdio.h>
#include<stdlib.h>
#include<sys/time.h>

#define VECTORSIZE 10

__global__ void matrixmul(int **A, int *B, int *C){ 
	int id = blockIdx.x*blockDim.x + threadIdx.x;  
    // for(int i=0;i<VECTORSIZE;i++){
		int sum = 0;
		for(int j=0; j<VECTORSIZE; j++){
			sum += A[id][j]*B[id];
		}
		C[id] = sum;
	// }    
}

int main(int argc, char **argv){

	int i, j;
	int **A, *B, *C;
	int **a1, *b1, *c1;	
	double exe_time;
	struct timeval stop_time, start_time;
	
	//Allocate and initialize the arrays
	A = (int **)malloc(VECTORSIZE*VECTORSIZE*sizeof(int));
	B = (int *)malloc(VECTORSIZE*sizeof(int));
	C = (int *)malloc(VECTORSIZE*sizeof(int));
	
	//Initialize data to some value
	for(i=0;i<VECTORSIZE;i++){
		for(j=0;j<VECTORSIZE;j++){
			A[i][j] = 1;	
		}
		B[i] = 1;
	}

	gettimeofday(&start_time, NULL);
    cudaMalloc(&a1, sizeof(A[0])/sizeof(A));
	cudaMemcpy(a1, A, sizeof(A[0])/sizeof(A), cudaMemcpyHostToDevice);
	cudaMalloc(&b1, sizeof(B[0])/sizeof(B));
	cudaMemcpy(b1, B, sizeof(B[0])/sizeof(B), cudaMemcpyHostToDevice);
	cudaMalloc(&c1, sizeof(C[0])/sizeof(C));
    matrixmul<<< 1,VECTORSIZE >>>(a1, b1, c1);
    cudaMemcpy(C, c1, sizeof(C[0])/sizeof(C), cudaMemcpyDeviceToHost);
	gettimeofday(&stop_time, NULL);	

	exe_time = (stop_time.tv_sec+(stop_time.tv_usec/1000000.0)) - (start_time.tv_sec+(start_time.tv_usec/1000000.0));
	
	//print the data
	printf("\nVector addition output: \n");
	for(i=0;i<VECTORSIZE;i++){
		printf("\t%d", C[i]);	
	}
	printf("\n\n Execution time is = %lf seconds\n", exe_time);
	
	printf("Program exit!\n");
	
	//Free arrays
	free(A); 
	free(B);
	free(C);
}
