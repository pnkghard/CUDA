#include<stdio.h>
#include<stdlib.h>


__global__ void arradd(int* md, int* nd, int* pd, int size)
{
	__shared__ int ms[400], ns[400];
	int myid = threadIdx.x;
	
	ms[myid] = md[myid];
	ns[myid] = nd[myid];

	__syncthreads();

	pd[myid] = ms[myid] + ns[myid];
}


int main()
{
	int size = 400 * sizeof(int);
	int m[400], n[400], p[400],*md, *nd,*pd;
	int i=0;

	
	for(i=0; i<400; i++ )
	{
		m[i] = i;
		n[i] = i;
		p[i] = 0;
	}

	cudaMalloc(&md, size);
	cudaMemcpy(md, m, size, cudaMemcpyHostToDevice);

	cudaMalloc(&nd, size);
	cudaMemcpy(nd, n, size, cudaMemcpyHostToDevice);

	cudaMalloc(&pd, size);

	dim3   DimGrid(1, 1);     
	dim3   DimBlock(400, 1);   


	arradd<<< DimGrid,DimBlock >>>(md,nd,pd,size);

	cudaMemcpy(p, pd, size, cudaMemcpyDeviceToHost);
	cudaFree(md); 
	cudaFree(nd);
	cudaFree (pd);

	for(i=0; i<400; i++ )
	{
		printf("\t%d",p[i]);
	}	

}




