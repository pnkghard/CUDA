#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<sys/time.h>

#define N 99999999
#define TB 128

__global__ void calc_area(double dx, double *aread){
	int i = blockIdx.x*blockDim.x + threadIdx.x;
	double x,y;
	double tmp;
	__shared__ double tmp_area[TB];
	tmp_area[threadIdx.x] = 0.0;
	if(i<N){	
		x = i*dx;
		y = sqrt(1-x*x);
		tmp_area[threadIdx.x] = y*dx;
	}
	__syncthreads();
	if(i<N){
		if(threadIdx.x == 0){
			tmp = 0.0;
			for(int j=0;j<TB;j++){
				tmp += tmp_area[j];
			}
			aread[blockIdx.x] = tmp;
		}
	}
}

int main(){
	int i;
	double total_area, pi, *area, *aread;
	double dx;
	double exe_time;
	struct timeval stop_time, start_time;
	
	dx = 1.0/N;
	total_area = 0.0;
	
	gettimeofday(&start_time, NULL);
	int maxThread = N;
	int blocks = maxThread / TB + 1;
	
	area = (double *)malloc(blocks*sizeof(double));
	cudaMalloc(&aread, blocks*sizeof(double));
	
	calc_area<<<blocks,TB>>>(dx, aread);
	
	cudaMemcpy(area,aread,blocks*sizeof(double),cudaMemcpyDeviceToHost);
	
	for(i=0;i<blocks;i++){
		total_area += area[i];	
	}
	
	gettimeofday(&stop_time, NULL);	
	exe_time = (stop_time.tv_sec+(stop_time.tv_usec/1000000.0)) - (start_time.tv_sec+(start_time.tv_usec/1000000.0));
	
	pi = 4.0*total_area;
	printf("\n Value of pi is = %lf\n Execution time is = %lf seconds\n", pi, exe_time);
	
	free(area);
	cudaFree(aread);
	
}