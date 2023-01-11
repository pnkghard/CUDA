#include<stdio.h>
#include<stdlib.h>

__global__ void function(double* md, double* nd, double* pd, double al){

	int myid = blockIdx.x*blockDim.x + threadIdx.x;

	pd[myid] = md[myid] + al*nd[myid];
}


int main()
{
	double size = 400 * sizeof(double);
	double a[400], b[400], c[400], alpha, *md, *nd, *pd;
	int i=0;
	
	alpha = 0.001;

	for(i=0; i<400; i++ ){
		a[i] = i;
		b[i] = i;
		c[i] = 0;
	}

	cudaMalloc(&md, size);
	cudaMemcpy(md, a, size, cudaMemcpyHostToDevice);

	cudaMalloc(&nd, size);
	cudaMemcpy(nd, b, size, cudaMemcpyHostToDevice);

	cudaMalloc(&pd, size);

	dim3   DimGrid(1, 1);     
	dim3   DimBlock(400, 1);   


	function<<< DimGrid,DimBlock >>>(md,nd,pd,alpha);

	cudaMemcpy(c, pd, size, cudaMemcpyDeviceToHost);

	for(i=0; i<400; i++ ){
		printf("\t%lf",c[i]);
	}	

	cudaFree(md); 
	cudaFree(nd);
	cudaFree(pd);
}
