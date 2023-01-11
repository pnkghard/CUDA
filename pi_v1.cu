#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<sys/time.h>

#define N 9999999

double pi_cal(){
    double dx, x, area, y, pi;
    dx = 1.0/N;
    for(int i=0; i<N; i++){
        x = i*dx;
        y = sqrt(1-x*x);
        area += y*dx;
    }
    return 4.0*area;
}

int main(){
    struct timeval start, end;
    double pi = pi_cal();
    printf("Value of PI = %lf\n", pi);
    return 0;
}
