#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<sys/time.h>

#define N 99999999
#define NUM_THDS 512

__global__ void calc_area(double dx, double *aread)
{
	int i = blockIdx.x*blockDim.x + threadIdx.x;
	double x,y;
	if(i<N)
	{	
		x = i*dx;
		y = sqrt(1-x*x);
		aread[i] = y*dx;
	}
}
__global__ void calc_reduction(double *aread, double *aread2)
{
	int i = blockIdx.x*blockDim.x + threadIdx.x;
	int working_thds;
	__shared__ double tmp_area[NUM_THDS];
	tmp_area[threadIdx.x] = 0.0;
	if(i<N)
	{	
		tmp_area[threadIdx.x] = aread[i];
	}
	__syncthreads();
	if(i<N)
	{	
		working_thds = NUM_THDS;
		while(1)
		{
			working_thds = working_thds/2;
			if(threadIdx.x < working_thds)
			{
				tmp_area[threadIdx.x] = tmp_area[threadIdx.x] + tmp_area[threadIdx.x + working_thds]; 
			}
			if(working_thds == 1)
			{
				break;
			}
			__syncthreads();
		}
		if(threadIdx.x == 0)
		{		
			aread2[blockIdx.x] = tmp_area[0];
		}
	}

}
int main()
{
	int i;
	double total_area, pi, *area, *aread,*aread2;
	double dx;
	double exe_time;
	struct timeval stop_time, start_time;
	
	dx = 1.0/N;
	total_area = 0.0;
	
	gettimeofday(&start_time, NULL);
	
	int num_threads_per_block = NUM_THDS;
	int total_threads = N;
	int num_blocks = total_threads / num_threads_per_block + 1;
	
	area = (double *)malloc(num_blocks*sizeof(double));
	cudaMalloc(&aread, N*sizeof(double));
	cudaMalloc(&aread2, num_blocks*sizeof(double));
	
	calc_area<<<num_blocks,num_threads_per_block>>>(dx, aread);
	calc_reduction<<<num_blocks,num_threads_per_block>>>(aread,aread2);

	
	cudaMemcpy(area,aread2,num_blocks*sizeof(double),cudaMemcpyDeviceToHost);
	
	for(i=0;i<num_blocks;i++)
	{
		total_area += area[i];	
	}
	/*for(i=0;i<N;i++)
	{
		x = i*dx;
		y = sqrt(1-x*x);
		area += y*dx;
	}*/
	
	gettimeofday(&stop_time, NULL);	
	exe_time = (stop_time.tv_sec+(stop_time.tv_usec/1000000.0)) - (start_time.tv_sec+(start_time.tv_usec/1000000.0));
	
	pi = 4.0*total_area;
	printf("\n Value of pi is = %.16lf\n Execution time is = %lf seconds\n", pi, exe_time);
	
	free(area);
	cudaFree(aread);
	
}

