#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>
#include <cstdlib>
#include <stdio.h>
#include <math.h>
#include <ctime>

#define T 1024 // max threads per block

using namespace std;

uint64_t value_of_number(uint64_t *numer)
{
	uint64_t pierwsza;
	pierwsza = pow(2, 61);

	//uint64_t hehe;
	//hehe = pow(2, 19);
	//hehe = 256203221;
	//hehe = 275604547;
	//hehe = 452930477;
	//hehe = 53;


	*numer = pierwsza - 1;
	//*numer = 53*53;
	//*numer = (hehe - 1)*(hehe - 1);
	//*numer = (hehe)*(hehe);

	//cout << "Podaj liczbe: ";
	//cin >> *numer;

	cout << *numer << endl;
	cout << (uint64_t)sqrt(*numer) << endl << endl;

	return *numer;
}

__global__ void check_prime(uint64_t *numer, bool *flaga)
{
	uint64_t i = threadIdx.x + blockIdx.x * blockDim.x;
	if((*numer % i == 0) && (i >= 2) && (i<*numer))
	{
		printf("Mod %d = %d \n", i, *numer % i);
		*flaga = false;
	}
}

__global__ void check_prime(uint64_t *numer, bool *flaga, int *increase)
{
	uint64_t i = threadIdx.x + blockIdx.x * blockDim.x + *increase*204800000;
	if ((*numer % i == 0) && (i >= 2) && (i<*numer))
	{
		printf("Mod %d = %d \n", i, *numer % i);
		*flaga = false;
	}
}

bool if_prime_cpu(uint64_t x)
{
	if (x < 2)
		return false;
	for (uint64_t i = 2; i*i <= x; i++)
	{
		if (x % i == 0)
		{
			printf("Mod %d = %d \n", i, x % i);
			return false;
		}
	}
	return true;
}

bool if_prime_gpu(bool *flaga, bool *dev_flaga, uint64_t *dev_numer, int *increase, int *dev_increase)
{
	cudaMemcpy(dev_increase, increase, sizeof(int), cudaMemcpyHostToDevice);

	// Launch a kernel on the GPU
	check_prime << <200000, T >> >(dev_numer, dev_flaga, dev_increase);
	cudaDeviceSynchronize();

	cudaMemcpy(flaga, dev_flaga, sizeof(bool), cudaMemcpyDeviceToHost);

	return *flaga;
}

bool if_prime_gpu(bool *flaga, bool *dev_flaga, uint64_t *dev_numer, uint64_t N)
{
	// Launch a kernel on the GPU
	check_prime << <N, T >> >(dev_numer, dev_flaga);
	cudaDeviceSynchronize();

	cudaMemcpy(flaga, dev_flaga, sizeof(bool), cudaMemcpyDeviceToHost);

	return *flaga;
}

int main()
{
	// zadeklarowanie zmiennych
	uint64_t *numer = new uint64_t;
	uint64_t *sqrt_numer = new uint64_t;

	bool *flaga = new bool;
	int *increase = new int;
	
		*flaga = true;
		*increase = 0;

		// przypisanie wartoœci
		value_of_number(numer);
		*sqrt_numer = (uint64_t)sqrt(*numer);

		// sprawdenie za pomoc¹ CPU
		clock_t startCPU = clock();
		if (if_prime_cpu(*numer))
			cout << "CPU - tak" << endl;
		else
			cout << "CPU - nie" << endl;
		printf("Czas wykonywania na CPU: %.4fs\n\n", (double)(clock() - startCPU) / CLOCKS_PER_SEC);


		uint64_t N = ceil((uint64_t)sqrt(*numer) / T) + 1;

		uint64_t *dev_numer = 0;
		bool *dev_flaga = false;
		int *dev_increase = 0;

		// Choose which GPU to run on, change this on a multi-GPU system.
		cudaSetDevice(0);

		// Allocate GPU buffers for input and output
		cudaMalloc((void**)&dev_numer, sizeof(uint64_t));
		cudaMalloc((void**)&dev_flaga, sizeof(bool));
		cudaMalloc((void**)&dev_increase, sizeof(int));

		// Copy input from host memory to GPU buffers
		cudaMemcpy(dev_numer, numer, sizeof(uint64_t), cudaMemcpyHostToDevice);
		cudaMemcpy(dev_flaga, flaga, sizeof(bool), cudaMemcpyHostToDevice);

		// sprawdenie za pomoc¹ GPU
		clock_t startGPU = clock();
		if (*sqrt_numer > 244800000)
		{
			while (*flaga && (*increase) * 204800000 < *sqrt_numer) {
				*flaga = if_prime_gpu(flaga, dev_flaga, dev_numer, increase, dev_increase);
				*increase = *increase + 1;
			}
		}
		else
		{
			*flaga = if_prime_gpu(flaga, dev_flaga, dev_numer, N);
		}

		if (*flaga)
			cout << "GPU - tak" << endl;
		else
			cout << "GPU - nie" << endl;
		printf("Czas wykonywania na GPU: %.4fs\n", (double)(clock() - startGPU) / CLOCKS_PER_SEC);
	
		cudaFree(dev_numer);
		cudaFree(dev_flaga);
		cudaFree(dev_increase);

	// cudaDeviceReset must be called before exiting in order for profiling and
	// tracing tools such as Nsight and Visual Profiler to show complete traces.
	cudaDeviceReset();

	system("pause");
	return 0;
}