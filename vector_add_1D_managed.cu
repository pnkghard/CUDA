#include<stdio.h>
#include<stdlib.h>
#define N 200

__global__ void arradd(int* md, int* nd, int* pd)
{
	int myid = threadIdx.x;
	
	pd[myid] = md[myid] + nd[myid];
}


int main()
{
	int *m, *n, *p;
	int i=0;

        cudaMallocManaged(&m, N*sizeof(int));
	cudaMallocManaged(&n, N*sizeof(int));
	cudaMallocManaged(&p, N*sizeof(int));
	
	for(i=0; i<N; i++ )
	{
		m[i] = i;
		n[i] = i;
		p[i] = 0;
	}  
	arradd<<< 1,N >>>(m,n,p);
	cudaDeviceSynchronize();
	for(i=0; i<N; i++ )
	{
		printf("\t%d",p[i]);
	}	
	cudaFree(m);
	cudaFree(n);
	cudaFree(p);	
}




