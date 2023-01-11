#include<stdio.h>
#include<stdlib.h>
#include<math.h>

#define N 10000000000


__device__ int isprime(int num){
    for(int i=2; i<=num/2; i++){
        if(num%i==0){
            return 0;
        }
    }
    return 1;
}

__global__ void countprime(int* prime){
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i>=2 && i<=N){
        prime[i] = isprime(i);
    }
}

int main(){
    int size = N*sizeof(int);
	int prime[N], *p, count;
    //initializing array
    for(int i=0; i<N; i++){
        prime[i] = 0;       
    }
    // mem allocation and grid define
    cudaMalloc(&p, size);
    int maxThread = 256;
    int blocks = (N/maxThread) + 1;
    //kernal
	countprime<<<N,blocks>>>(p);
    cudaMemcpy(prime, p, size, cudaMemcpyDeviceToHost);//device to host

    for(int i=0; i<N; i++){
        count += prime[i];
    }

    printf("Total Prime Number : %d\n", count);
}