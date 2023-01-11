#include<stdio.h>
#include<stdlib.h>


__global__ void addmatrix(int* md, int* nd, int* pd){
    int myid = threadIdx.y * blockDim.x + threadIdx.x;
    pd[myid] = md[myid] + nd[myid];
}


int main(){
    int size = 20 * 20 * sizeof(int);
    int m[20][20], n[20][20], p[20][20], *md, *nd, *pd;
    int i=0, j=0;
    // initialization of matrix
    for(i=0; i<20; i++){
        for(j=0; j<20; j++){
            m[i][j] = i;
            n[i][j] = i;
            p[i][j] = 0;
        }
    }
    //memory allocation
    cudaMalloc(&md, size);
    cudaMemcpy(md, m, size, cudaMemcpyHostToDevice);//cpu to gpu copy
    cudaMalloc(&nd, size);
    cudaMemcpy(nd, n, size, cudaMemcpyHostToDevice);
    cudaMalloc(&pd, size);
    //thread creation
    dim3 dimgrid(1, 1);
    dim3 dimblock(20, 20);
    addmatrix<<<dimgrid, dimblock>>>(md, nd, pd);
    cudaMemcpy(p, pd, size, cudaMemcpyDeviceToHost);//gpu to cpu copy
    for(i=0; i<20; i++){
        for(j=0; j<20; j++){
            printf("%d\t", p[i][j]);
        }
        printf("\n");
    }
    return 0;
}