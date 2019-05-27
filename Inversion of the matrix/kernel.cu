#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <ctime>
#include <iostream>
#include <stdio.h>
#include <cstdlib>

using namespace std;

const int dimension_size = 10240;
const int matrix_size = dimension_size * dimension_size;

const int block_size = 16; 
const int block_size_shared = 16;

__global__ void gpu_transpose(int *matrix_in, int *matrix_out)
{
	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;

	if(x < dimension_size && y < dimension_size)
		matrix_out[x* dimension_size + y] = matrix_in[y* dimension_size + x];
		//matrix_out[y* dimension_size + x] = matrix_in[x* dimension_size + y];
}

__global__ void gpu_transpose_shared(int *matrix_in, int *matrix_out)
{
	__shared__ int tile[block_size_shared+1][block_size_shared];

	int x = blockIdx.x * blockDim.x + threadIdx.x;
	int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < dimension_size && y < dimension_size)
		tile[threadIdx.x][threadIdx.y] = matrix_in[x * dimension_size + y];

	__syncthreads();	
	if (x < dimension_size && y < dimension_size)
		matrix_out[y * dimension_size + x] = tile[threadIdx.x][threadIdx.y];
}

void print_matrix(int *matrix)
{
	for (int i = 0; i < dimension_size; i++) {
		cout << endl;
		for (int j = 0; j < dimension_size; j++) {
			cout << matrix[i*dimension_size + j] << " ";
		}
	}
	cout << endl;
}

void create_matrix(int *matrix)
{
	printf("Transponowanie macierzy: %d x %d\n\n", dimension_size, dimension_size);

	for (int i = 0; i < dimension_size; i++) {
		for (int j = 0; j < dimension_size; j++) {
			matrix[i*dimension_size + j] = rand() % 50;
		}
	}
}

double cpu_transpose(clock_t start, clock_t end, int *matrix_in, int *matrix_out)
{
	start = clock();
	for (int i = 0; i < dimension_size; i++) {
		for (int j = 0; j < dimension_size; j++) {
			matrix_out[j*dimension_size + i] = matrix_in[i*dimension_size + j];
		}
	}
	end = clock();

	double difference_cpu = (double)(end - start) / CLOCKS_PER_SEC;
	printf("Czas wykonywania CPU: %.4f s\n\n", difference_cpu);

	return difference_cpu;
}

void gpu_transpose(clock_t start, clock_t end, int *matrix_out_gpu, int *dev_matrix_out, int *dev_matrix_in, double difference_cpu)
{
	// USTALANIE WIELKOŒCI BLOKU
	int threads_size;
	if (dimension_size % block_size == 0)
		threads_size = (int)(dimension_size / block_size);
	else
		threads_size = (int)(dimension_size / block_size) + 1;

	dim3 blocks(block_size, block_size, 1);
	dim3 threads(threads_size, threads_size, 1);

	start = clock();
	gpu_transpose << <threads, blocks >> > (dev_matrix_in, dev_matrix_out);
	cudaDeviceSynchronize();
	cudaMemcpy(matrix_out_gpu, dev_matrix_out, matrix_size*sizeof(int), cudaMemcpyDeviceToHost);
	end = clock();

	double difference_gpu = (double)(end - start) / CLOCKS_PER_SEC;
	printf("Czas wykonywania GPU: %.4f s\n", difference_gpu);

	cudaGetLastError();

	cudaMemcpy(dev_matrix_out, matrix_out_gpu, matrix_size*sizeof(int), cudaMemcpyHostToDevice);

	printf("Przyspieszenie CPU-GPU:\t\t %.4f - krotne\n\n", difference_cpu / difference_gpu);
}

void gpu_transpose_shared(clock_t start, clock_t end, int *matrix_out_gpu_shared, int *dev_matrix_out, int *dev_matrix_in, double difference_cpu)
{
	// USTALANIE WIELKOŒCI BLOKU
	int threads_size;
	if (dimension_size % block_size_shared == 0)
		threads_size = (int)(dimension_size / block_size_shared);
	else
		threads_size = (int)(dimension_size / block_size_shared) + 1;

	dim3 blocks(block_size_shared, block_size_shared, 1);
	dim3 threads(threads_size, threads_size, 1);

	cudaMemcpy(dev_matrix_out, matrix_out_gpu_shared, matrix_size*sizeof(int), cudaMemcpyHostToDevice);

	start = clock();
	gpu_transpose_shared << <threads, blocks >> > (dev_matrix_in, dev_matrix_out);
	cudaDeviceSynchronize();
	cudaMemcpy(matrix_out_gpu_shared, dev_matrix_out, matrix_size*sizeof(int), cudaMemcpyDeviceToHost);
	end = clock();


	double difference_gpu_shared = (double)(end - start) / CLOCKS_PER_SEC;
	printf("Czas wykonywania GPU: %.4f s\n", difference_gpu_shared);

	cudaGetLastError();

	printf("Przyspieszenie CPU-GPU shared:\t %.4f - krotne\n\n", difference_cpu / difference_gpu_shared);
}

void check_matrix(int *matrix_out_cpu, int *matrix_out_gpu, int *matrix_out_gpu_shared)
{
	bool flag = true;
	bool flag_shared = true;
	for (int i = 0; i < dimension_size; i++) {
		for (int j = 0; j < dimension_size; j++) {
			if (matrix_out_cpu[i*dimension_size + j] != matrix_out_gpu[i*dimension_size + j])
				flag = false;
			if (matrix_out_cpu[i*dimension_size + j] != matrix_out_gpu_shared[i*dimension_size + j])
				flag_shared = false;
		}
	}

	cout << "Macierze: " << endl;
	if (flag)
		cout << "CPU-GPU\t\t - takie same" << endl;
	else
		cout << "CPU-GPU\t\t - inne" << endl;

	if (flag_shared)
		cout << "CPU-GPU shared\t - takie same" << endl;
	else
		cout << "CPU-GPU shared\t - inne" << endl;
}

int main()
{
	bool show = false;
	// ZMIENNE
	int *matrix_in;
	int *matrix_out_cpu;
	int *matrix_out_gpu;
	int *matrix_out_gpu_shared;

	matrix_in = (int*)malloc(matrix_size*sizeof(int));
	matrix_out_cpu = (int*)malloc(matrix_size*sizeof(int));
	matrix_out_gpu = (int*)malloc(matrix_size*sizeof(int));
	matrix_out_gpu_shared = (int*)malloc(matrix_size*sizeof(int));

	int *dev_matrix_in;
	int *dev_matrix_out;

	clock_t start = clock();
	clock_t end = clock();

	// TWORZENIE MACIERZY
	create_matrix(matrix_in);
	//show(matrix_in);

	// TRANSPONOWANIE CPU
	double difference_cpu = cpu_transpose(start, end, matrix_in, matrix_out_cpu);
	if(show) print_matrix(matrix_out_cpu);

	// ALOKOWANIE ZMIENNYCH DO GPU
	cudaSetDevice(0);

	cudaMalloc((void**)&dev_matrix_in, matrix_size*sizeof(int));
	cudaMalloc((void**)&dev_matrix_out, matrix_size*sizeof(int));

	cudaMemcpy(dev_matrix_in, matrix_in, matrix_size*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_matrix_out, matrix_out_gpu, matrix_size*sizeof(int), cudaMemcpyHostToDevice);

	// TRANSPONOWANIE GPU
	gpu_transpose(start, end, matrix_out_gpu, dev_matrix_out, dev_matrix_in, difference_cpu);
	if (show) print_matrix(matrix_out_gpu);
	
	// TRANSPONOWANIE GPU SHARED
	gpu_transpose_shared(start, end, matrix_out_gpu_shared, dev_matrix_out, dev_matrix_in, difference_cpu);
	if (show) print_matrix(matrix_out_gpu_shared);
	
	cudaFree(dev_matrix_in);
	cudaFree(dev_matrix_out);	
	cudaDeviceReset();

	// SPRAWDZENIE POPRAWNIOŒCI
	check_matrix(matrix_out_cpu, matrix_out_gpu, matrix_out_gpu_shared);

	free(matrix_in);
	free(matrix_out_cpu);
	free(matrix_out_gpu);
	free(matrix_out_gpu_shared);

	system("pause");
    return 0;
}