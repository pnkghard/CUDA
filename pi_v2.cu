#include<stdio.h>
#include<stdlib.h>
#include<math.h>

#define N 999999
#define maxThread 256

__global__ void pi_cal(double* area){
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    double x, y, dx=1.0/N;
    if(i<N){
        x = i*dx;
        y = sqrt(1-x*x);
        area[i] = y*dx;
    }
}

int main(){
    double *pi, *p, sum;
    pi = (double *)malloc(N*sizeof(double));
    cudaMalloc(&p, N*sizeof(double));
    int blocks = (N/maxThread) + 1;
	pi_cal<<<blocks, maxThread>>>(p);
    cudaMemcpy(pi, p, N*sizeof(double), cudaMemcpyDeviceToHost);
    for(int i=0; i<N; i++){
        sum+=pi[i];
    }
    sum = 4.0*sum;
    printf("Value of PI = %lf\n", sum);
    return 0;
}