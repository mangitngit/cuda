
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <ctime>
#include <iostream>
#include <stdio.h>
#include <cstdlib>

using namespace std;

const unsigned long int vectorsize = 436870912;
const int block_size = 1;
const int thread_size = 1024;

__global__ void reduce_vector(double *vector)
{
	int thread = threadIdx.x;
	__shared__ double bufor[thread_size];

	bufor[thread] = 0;
	for (unsigned long int i = thread; i < vectorsize; i += blockDim.x)
		bufor[thread] += vector[i];

	__syncthreads();

	if (thread == 0)
	{
		for (int i = 1; i < blockDim.x; i++)
			bufor[0] += bufor[i];
		
		vector[0] = bufor[0];
	}
}

void create_vector(double *vector)
{
	for (unsigned long int i = 0; i < vectorsize; i++)
	{
		//double a = (rand() % 44);
		//double b = (rand() % 44)+1;
		//vector[i] = (a / b);
		vector[i] = (rand() % 44);
		//cout << vector[i] << endl;
	}
}

int main()
{
	// ZMIENNE
	double *vector;
	double suma_cpu = 0;
	double suma_gpu = 0;

	vector = (double*)malloc(vectorsize*sizeof(double));

	double *dev_vector;

	clock_t start = clock();
	clock_t end = clock();

	start = clock();
	// WYPE£NIANIE WEKTORA RANDOMAMI
	create_vector(vector);
	end = clock();

		
	printf("Macierz wypelniona\n");

	// SUMOWANIE CPU
	start = clock();
	for (unsigned long int i = 0; i < vectorsize; i++) {
		suma_cpu += vector[i];
	}
	end = clock();


	double difference_cpu = (double)(end - start) / CLOCKS_PER_SEC;
	printf("\nCzas wykonywania CPU: %.4f s\n", difference_cpu);
	printf("Suma = %.2f \n\n", suma_cpu);

	// ALOKOWANIE ZMIENNYCH DO GPU
	cudaSetDevice(0);

	cudaMalloc((void**)&dev_vector, vectorsize*sizeof(double));
	cudaMemcpy(dev_vector, vector, vectorsize*sizeof(double), cudaMemcpyHostToDevice);

	start = clock();
	reduce_vector << <block_size, thread_size >> >(dev_vector);
	cudaDeviceSynchronize();
	end = clock();
	cudaMemcpy(vector, dev_vector, vectorsize*sizeof(double), cudaMemcpyDeviceToHost);
	

	cudaGetLastError();
	
	suma_gpu = vector[0];

	double difference_gpu = (double)(end - start) / CLOCKS_PER_SEC;
	printf("Czas wykonywania GPU: %.4f s\n", difference_gpu);
	printf("Suma = %.2f \n\n", suma_gpu);

	if (suma_cpu == suma_gpu)
		printf("Wyniki sa takie same\n");
	else
		printf("ERROR ERROR\n");

	printf("Przyspieszenie CPU-GPU:\t\t %.4f - krotne\n\n", difference_cpu / difference_gpu);

	cudaFree(dev_vector);

	cudaDeviceReset();

	free(vector);
	
	system("pause");
	return 0;
}




