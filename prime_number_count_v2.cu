#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<sys/time.h>

#define N 1000000
#define NUM_THDS 256 
/*
                N  PRIME_NUMBER

                1           0
               10           4
              100          25
            1,000         168
           10,000       1,229
          100,000       9,592
        1,000,000      78,498
       10,000,000     664,579
      100,000,000   5,761,455
    1,000,000,000  50,847,534

*/

__global__ void prime_count(int *countd)
{
	int i = blockIdx.x*blockDim.x+threadIdx.x;
	int flag = 0;
	int j;
	int count = 0;
	__shared__ int tmp_count[NUM_THDS];
	if(i<N)
        {
        	tmp_count[threadIdx.x] = 0;
        }
	if((i>2)&&(i<N))
	{
		for(j=2;j<i;j++)	
	    	{
		    if((i%j) == 0)
		    {
			    flag = 1;
			    break;
		    }
	    	}
        	if(flag == 0)
        	{
            		tmp_count[threadIdx.x] = 1;
        	}
        	else
        	{
            		tmp_count[threadIdx.x] = 0;
        	}
        }
        __syncthreads();
        if(i<N)
        {
        	if(threadIdx.x == 0)
        	{
        		for(j=0;j<NUM_THDS;j++)
        		{
        			if(tmp_count[j] == 1)
        			{
        				count++;
        			}
        		}
        		countd[blockIdx.x] = count;
        	}
        }
}



int main()
{
	int i, j;
	int count, flag, *cnt, *cntd;
	double exe_time;
	struct timeval stop_time, start_time;
	
	count = 1; // 2 is prime. Our loop starts from 3
	
	gettimeofday(&start_time, NULL);
	
	/*for(i=3;i<N;i++)
	{
	 	flag = 0;
		for(j=2;j<i;j++)	
	    	{
		    if((i%j) == 0)
		    {
			    flag = 1;
			    break;
		    }
	    	}
        	if(flag == 0)
        	{
            		count++;
        	}
	}*/
	
	int num_threads_per_block = NUM_THDS;
	int total_threads = N;
	int num_blocks = total_threads / num_threads_per_block + 1; 
	
	cnt = (int *)malloc(num_blocks*sizeof(int));
	cudaMalloc(&cntd,num_blocks*sizeof(int));
	
	 
	
	prime_count<<<num_blocks,num_threads_per_block>>>(cntd);
	
	cudaMemcpy(cnt,cntd,num_blocks*sizeof(int),cudaMemcpyDeviceToHost);
	
	for(i=0;i<num_blocks;i++)
	{
		count+= cnt[i];
	}
	
	
	gettimeofday(&stop_time, NULL);	
	exe_time = (stop_time.tv_sec+(stop_time.tv_usec/1000000.0)) - (start_time.tv_sec+(start_time.tv_usec/1000000.0));
	
	printf("\n Number of prime numbers = %d \n Execution time is = %lf seconds\n", count, exe_time);
	
	free(cnt);
	cudaFree(cntd);
	
}

