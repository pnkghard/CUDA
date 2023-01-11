#include<stdio.h>
#include<stdlib.h>

__device__ int calc_square(int val){
	int val_square;
	val_square = val*val;
	return val_square;
}


__global__ void square(int *array, int* square){
	int id = blockIdx.x*blockDim.x + threadIdx.x;
	square[id] = calc_square(array[id]);
}

int main()
{
	int size = 400 * sizeof(int);
	int a[400], aa[400], *a1, *s;
	int i=0;
	

	//Initialize the vectors
	for(i=0; i<400; i++ )
	{
		a[i] = i;
		aa[i] = 0;
	}


	cudaMalloc(&a1, size);
	cudaMemcpy(a1, a, size, cudaMemcpyHostToDevice);
	cudaMalloc(&s, size);
	

	dim3   DimGrid(1, 1);     
	dim3   DimBlock(400, 1);

	square<<< DimGrid, DimBlock >>>(a1, s);
	cudaMemcpy(aa, s, size, cudaMemcpyDeviceToHost);

	for(i=0; i<400; i++ ){
		printf("\t%d",aa[i]);
	}	
}
