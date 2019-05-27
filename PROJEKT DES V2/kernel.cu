#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <device_functions.h>

#include <cstdlib>
#include <assert.h>
#include <stdio.h>
#include <iostream>
#include <ctime>
#include <cmath>
#include <math.h> 

# include "cuda_runtime.h"
# include "device_launch_parameters.h"
# include <stdio.h>
# include <fstream>
# include <string>
# include <iostream>
# include <stdlib.h>
# include <vector>
# include <ctime>
# include <array>

using namespace std;
int en_de;
string input;
string obraz_cpu;
string obraz_gpu;

void przypisz(int tabin[64], int tabout[64])
{
	for (int i = 0; i < 64; i++) tabout[i] = tabin[i];
}
void podzial(int datatab[64], int tabl[64], int tabr[64])
{
	for (int i = 0; i < 32; i++)
	{
		tabl[i] = datatab[i];
		tabr[i] = datatab[i + 32];

	}
}
void polaczenie(int datatab[64], int tabl[64], int tabr[64])
{
	for (int i = 0; i < 32; i++)
	{
		datatab[i] = tabl[i];
		datatab[i + 32] = tabr[i];

	}
}
void zamiana(int l, int tab[64], int index)
{
	int suma = l;
	for (int i = 3; i >= 0; i--)
	{
		if (suma >= pow(2, i)) {
			suma = suma - pow(2, i);
			tab[3 + index - i] = 1;
		}
		else tab[3 + index - i] = 0;
	}
}

void rysuj(int tabin[64], int ile, int rzadek)
{
	for (int j = 0; j < ile; j++)
	{
		cout << tabin[j] << " ";
		if ((j + 1) % rzadek == 0)cout << endl;
	}
}
void wypelnij(int tabin[64])
{
	for (unsigned long int i = 0; i < 64; i++)
	{
		tabin[i] = i + 1;
	}
}

void IP(int tabin[64], int tabout[64])
{

	for (int i = 0; i < 8; i++)
	{
		tabout[i] = tabin[57 - 8 * i];
		tabout[i + 8] = tabin[59 - 8 * i];
		tabout[i + 16] = tabin[61 - 8 * i];
		tabout[i + 24] = tabin[63 - 8 * i];
		tabout[i + 32] = tabin[56 - 8 * i];
		tabout[i + 40] = tabin[58 - 8 * i];
		tabout[i + 48] = tabin[60 - 8 * i];
		tabout[i + 56] = tabin[62 - 8 * i];
	}
}

void IP_1(int tabin[64], int tabout[64])
{
	for (int i = 0; i < 8; i++)
	{
		tabout[8 * i] = tabin[39 - i];
		tabout[8 * i + 1] = tabin[7 - i];
		tabout[8 * i + 2] = tabin[47 - i];
		tabout[8 * i + 3] = tabin[15 - i];
		tabout[8 * i + 4] = tabin[55 - i];
		tabout[8 * i + 5] = tabin[23 - i];
		tabout[8 * i + 6] = tabin[63 - i];
		tabout[8 * i + 7] = tabin[31 - i];
	}
}

void P_roz(int tabin[64], int tabout[64])
{
	tabout[0] = tabin[31];
	for (int i = 0; i < 5; i++)
	{
		tabout[1 + i] = tabin[i];
		tabout[42 + i] = tabin[27 + i];
	}
	for (int i = 0; i < 6; i++)
	{
		tabout[6 + i] = tabin[i + 3];
		tabout[12 + i] = tabin[7 + i];
		tabout[18 + i] = tabin[11 + i];
		tabout[24 + i] = tabin[15 + i];
		tabout[30 + i] = tabin[19 + i];
		tabout[36 + i] = tabin[23 + i];
	}
	tabout[47] = tabin[0];
}

void xor(int tabr[64], int tabkey[64], int numberofbits)
{
	for (int i = 0; i < numberofbits; i++)
	{
		if (tabr[i] == tabkey[i])tabr[i] = 0;
		else tabr[i] = 1;
	}
}

void PC_1(int tabin[64], int  tabout[64])
{
	for (int i = 0; i < 8; i++)
	{
		tabout[i] = tabin[56 - i * 8];
		tabout[i + 8] = tabin[57 - i * 8];
		tabout[i + 16] = tabin[58 - i * 8];
		tabout[i + 28] = tabin[62 - i * 8];
		tabout[i + 36] = tabin[61 - i * 8];
		tabout[i + 44] = tabin[60 - i * 8];
	}
	for (int i = 0; i < 4; i++)
	{
		tabout[i + 24] = tabin[59 - i * 8];
		tabout[i + 52] = tabin[27 - i * 8];
	}
}

void PC_2(int tabin[64], int  tabout[64])
{
	int  index[48] = { 14, 17, 11, 24, 1, 5, 3, 28, 15, 6, 21, 10, 23, 19, 12, 4, 26, 8, 16, 7, 27, 20, 13, 2, 41, 52, 31, 37, 47, 55, 30, 40, 51, 45, 33, 48, 44, 49, 39, 56, 34, 53, 46, 42,
		50, 36, 29, 32 };
	for (int i = 0; i < 48; i++)
	{
		tabout[i] = tabin[index[i] - 1];
	}
}

void P_P_bloku(int tabin[64], int  tabout[64])
{
	int index[32] = { 16, 7, 20, 21, 29, 12, 28, 17, 1, 15, 23, 26, 5, 18, 31, 10, 2, 8, 24, 14, 32, 27, 3, 9, 19, 13, 30, 6, 22, 11, 4, 25 };
	for (int i = 0; i < 32; i++)
	{
		tabout[i] = tabin[index[i] - 1];
	}
}

void S_blok(int tabin[64], int  tabout[64])
{
	int row = 0;
	int col = 0;
	int ls = 0;
	int ile = 0;
	int S[512] = { 14, 4, 13, 1, 2, 15, 11, 8, 3,
		10,
		6,
		12,
		5,
		9,
		0,
		7, // S1
		0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8, 4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0, 15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13, 15, 1, 8, 14, 6, 11, 3,
		4, 9, 7,
		2,
		13,
		12,
		0,
		5,
		10, // S2
		3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5, 0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15, 13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9, 10, 0, 9, 14, 6, 3, 15,
		5, 1, 13, 12,
		7,
		11,
		4,
		2,
		8, // S3
		13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1, 13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7, 1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12, 7, 13, 14, 3, 0, 6, 9,
		10, 1, 2, 8, 5,
		11,
		12,
		4,
		15, // S4
		13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9, 10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4, 3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14, 2, 12, 4, 1, 7, 10, 11,
		6, 8, 5, 3, 15, 13,
		0,
		14,
		9, // S5
		14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6, 4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14, 11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3, 12, 1, 10, 15, 9, 2, 6,
		8, 0, 13, 3, 4, 14, 7,
		5,
		11, // S6
		10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8, 9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6, 4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13, 4, 11, 2, 14, 15, 0, 8,
		13, 3, 12, 9, 7, 5, 10, 6,
		1, // S7
		13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6, 1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2, 6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12, 13, 2, 8, 4, 6, 15, 11,
		1, 10, 9, 3, 14, 5, 0, 12, 7, // S8
		1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2, 7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8, 2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11 };
	for (int i = 0; i < 8; i++)
	{
		row = tabin[i * 6] * 2 + tabin[i * 6 + 5];
		col = tabin[i * 6 + 1] * 8 + tabin[i * 6 + 2] * 4 + tabin[i * 6 + 3] * 2 + tabin[i * 6 + 4];
		ls = S[row * 16 + col + i * 64];
		ile = i * 4;
		zamiana(ls, tabout, ile);
	}
}

void key_f(int tabkey[64], int ktora, int tabout[64])
{
	int temp = 0;
	int temp1 = 0;
	int temp2 = 0;
	int temp3 = 0;
	int przesuniecie[16] = { 1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1 };
	if (przesuniecie[ktora] == 1)
	{
		for (int i = 0; i < 28; i++)
		{
			if (i == 0) temp = tabkey[0];
			if (i == 27)tabout[27] = temp;
			else tabout[i] = tabkey[i + 1];
			if (i == 0) temp1 = tabkey[28];
			if (i == 27)tabout[55] = temp1;
			else tabout[i + 28] = tabkey[i + 29];
		}
	}
	if (przesuniecie[ktora] == 2)
	{
		for (int i = 0; i < 28; i++)
		{
			if (i == 0) temp = tabkey[0];
			if (i == 0) temp2 = tabkey[1];
			if (i == 26)tabout[26] = temp;
			else
			{
				if (i == 27)tabout[27] = temp2;
				else tabout[i] = tabkey[i + 2];
			}
			if (i == 0) temp1 = tabkey[28];
			if (i == 0) temp3 = tabkey[29];
			if (i == 26)tabout[54] = temp1;
			else
			{
				if (i == 27)tabout[55] = temp3;
				else tabout[i + 28] = tabkey[i + 30];
			}
		}
	}
}

void funkcja_f(int tabr[64], int tabkey[64], int tabout[64])
{
	P_roz(tabr, tabout);
	xor (tabout, tabkey, 48);
	S_blok(tabout, tabr);
	P_P_bloku(tabr, tabout);
	przypisz(tabout, tabr);
}

void keys(int tabin[64], int tabout[16][64], int temp[64])
{
	PC_1(tabin, temp);
	for (int i = 0; i < 16; i++)
	{
		key_f(temp, i, tabin);
		przypisz(tabin, temp);
		PC_2(tabin, tabout[i]);
	}
}
__device__ void gprzypisz(int tabin[64], int tabout[64])
{
	for (int i = 0; i < 64; i++) tabout[i] = tabin[i];
}
__device__ void gpodzial(int datatab[64], int tabl[64], int tabr[64])
{
	for (int i = 0; i < 32; i++)
	{
		tabl[i] = datatab[i];
		tabr[i] = datatab[i + 32];

	}
}
__device__ void gpolaczenie(int datatab[64], int tabl[64], int tabr[64])
{
	for (int i = 0; i < 32; i++)
	{
		datatab[i] = tabl[i];
		datatab[i + 32] = tabr[i];

	}
}
__device__ void gzamiana(int l, int tab[64], int index)
{
	int potega = 8;
	int suma = l;
	for (int i = 3; i >= 0; i--)
	{
		if (suma >= potega) {
			suma = suma - potega;
			tab[3 + index - i] = 1;
		}
		else tab[3 + index - i] = 0;
		potega = potega / 2;
	}
}

__device__ void gwypelnij(int tabin[64])
{
	for (unsigned long int i = 0; i < 64; i++)
	{
		tabin[i] = i + 1;
	}
}

__device__ void gIP(int tabin[64], int tabout[64])
{

	for (int i = 0; i < 8; i++)
	{
		tabout[i] = tabin[57 - 8 * i];
		tabout[i + 8] = tabin[59 - 8 * i];
		tabout[i + 16] = tabin[61 - 8 * i];
		tabout[i + 24] = tabin[63 - 8 * i];
		tabout[i + 32] = tabin[56 - 8 * i];
		tabout[i + 40] = tabin[58 - 8 * i];
		tabout[i + 48] = tabin[60 - 8 * i];
		tabout[i + 56] = tabin[62 - 8 * i];
	}
}

__device__ void gIP_1(int tabin[64], int tabout[64])
{
	for (int i = 0; i < 8; i++)
	{
		tabout[8 * i] = tabin[39 - i];
		tabout[8 * i + 1] = tabin[7 - i];
		tabout[8 * i + 2] = tabin[47 - i];
		tabout[8 * i + 3] = tabin[15 - i];
		tabout[8 * i + 4] = tabin[55 - i];
		tabout[8 * i + 5] = tabin[23 - i];
		tabout[8 * i + 6] = tabin[63 - i];
		tabout[8 * i + 7] = tabin[31 - i];
	}
}

__device__ void gP_roz(int tabin[64], int tabout[64])
{
	tabout[0] = tabin[31];
	for (int i = 0; i < 5; i++)
	{
		tabout[1 + i] = tabin[i];
		tabout[42 + i] = tabin[27 + i];
	}
	for (int i = 0; i < 6; i++)
	{
		tabout[6 + i] = tabin[i + 3];
		tabout[12 + i] = tabin[7 + i];
		tabout[18 + i] = tabin[11 + i];
		tabout[24 + i] = tabin[15 + i];
		tabout[30 + i] = tabin[19 + i];
		tabout[36 + i] = tabin[23 + i];
	}
	tabout[47] = tabin[0];
}

__device__ void gxor(int tabr[64], int tabkey[64], int numberofbits)
{
	for (int i = 0; i < numberofbits; i++)
	{
		if (tabr[i] == tabkey[i])tabr[i] = 0;
		else tabr[i] = 1;
	}
}

__device__ void gPC_1(int tabin[64], int  tabout[64])
{
	for (int i = 0; i < 8; i++)
	{
		tabout[i] = tabin[56 - i * 8];
		tabout[i + 8] = tabin[57 - i * 8];
		tabout[i + 16] = tabin[58 - i * 8];
		tabout[i + 28] = tabin[62 - i * 8];
		tabout[i + 36] = tabin[61 - i * 8];
		tabout[i + 44] = tabin[60 - i * 8];
	}
	for (int i = 0; i < 4; i++)
	{
		tabout[i + 24] = tabin[59 - i * 8];
		tabout[i + 52] = tabin[27 - i * 8];
	}
}

__device__ void gPC_2(int tabin[64], int  tabout[64])
{
	int  index[48] = { 14, 17, 11, 24, 1, 5, 3, 28, 15, 6, 21, 10, 23, 19, 12, 4, 26, 8, 16, 7, 27, 20, 13, 2, 41, 52, 31, 37, 47, 55, 30, 40, 51, 45, 33, 48, 44, 49, 39, 56, 34, 53, 46, 42,
		50, 36, 29, 32 };
	for (int i = 0; i < 48; i++)
	{
		tabout[i] = tabin[index[i] - 1];
	}
}

__device__ void gP_P_bloku(int tabin[64], int  tabout[64])
{
	int index[32] = { 16, 7, 20, 21, 29, 12, 28, 17, 1, 15, 23, 26, 5, 18, 31, 10, 2, 8, 24, 14, 32, 27, 3, 9, 19, 13, 30, 6, 22, 11, 4, 25 };
	for (int i = 0; i < 32; i++)
	{
		tabout[i] = tabin[index[i] - 1];
	}
}

__device__ void gS_blok(int tabin[64], int  tabout[64])
{
	int row = 0;
	int col = 0;
	int ls = 0;
	int ile = 0;
	int S[512] = { 14, 4, 13, 1, 2, 15, 11, 8, 3,
		10,
		6,
		12,
		5,
		9,
		0,
		7, // S1
		0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8, 4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0, 15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13, 15, 1, 8, 14, 6, 11, 3,
		4, 9, 7,
		2,
		13,
		12,
		0,
		5,
		10, // S2
		3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5, 0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15, 13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9, 10, 0, 9, 14, 6, 3, 15,
		5, 1, 13, 12,
		7,
		11,
		4,
		2,
		8, // S3
		13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1, 13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7, 1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12, 7, 13, 14, 3, 0, 6, 9,
		10, 1, 2, 8, 5,
		11,
		12,
		4,
		15, // S4
		13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9, 10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4, 3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14, 2, 12, 4, 1, 7, 10, 11,
		6, 8, 5, 3, 15, 13,
		0,
		14,
		9, // S5
		14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6, 4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14, 11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3, 12, 1, 10, 15, 9, 2, 6,
		8, 0, 13, 3, 4, 14, 7,
		5,
		11, // S6
		10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8, 9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6, 4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13, 4, 11, 2, 14, 15, 0, 8,
		13, 3, 12, 9, 7, 5, 10, 6,
		1, // S7
		13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6, 1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2, 6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12, 13, 2, 8, 4, 6, 15, 11,
		1, 10, 9, 3, 14, 5, 0, 12, 7, // S8
		1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2, 7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8, 2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11 };
	for (int i = 0; i < 8; i++)
	{
		row = tabin[i * 6] * 2 + tabin[i * 6 + 5];
		col = tabin[i * 6 + 1] * 8 + tabin[i * 6 + 2] * 4 + tabin[i * 6 + 3] * 2 + tabin[i * 6 + 4];
		ls = S[row * 16 + col + i * 64];
		ile = i * 4;
		gzamiana(ls, tabout, ile);
	}
}

__device__ void gkey_f(int tabkey[64], int ktora, int tabout[64])
{
	int temp = 0;
	int temp1 = 0;
	int temp2 = 0;
	int temp3 = 0;
	int przesuniecie[16] = { 1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1 };
	if (przesuniecie[ktora] == 1)
	{
		for (int i = 0; i < 28; i++)
		{
			if (i == 0) temp = tabkey[0];
			if (i == 27)tabout[27] = temp;
			else tabout[i] = tabkey[i + 1];
			if (i == 0) temp1 = tabkey[28];
			if (i == 27)tabout[55] = temp1;
			else tabout[i + 28] = tabkey[i + 29];
		}
	}
	if (przesuniecie[ktora] == 2)
	{
		for (int i = 0; i < 28; i++)
		{
			if (i == 0) temp = tabkey[0];
			if (i == 0) temp2 = tabkey[1];
			if (i == 26)tabout[26] = temp;
			else
			{
				if (i == 27)tabout[27] = temp2;
				else tabout[i] = tabkey[i + 2];
			}
			if (i == 0) temp1 = tabkey[28];
			if (i == 0) temp3 = tabkey[29];
			if (i == 26)tabout[54] = temp1;
			else
			{
				if (i == 27)tabout[55] = temp3;
				else tabout[i + 28] = tabkey[i + 30];
			}
		}
	}
}

__device__ void gfunkcja_f(int tabr[64], int tabkey[64], int tabout[64])
{
	gP_roz(tabr, tabout);
	gxor(tabout, tabkey, 48);
	gS_blok(tabout, tabr);
	gP_P_bloku(tabr, tabout);
	gprzypisz(tabout, tabr);
}

__device__ void gkeys(int tabin[64], int tabout[16][64], int temp[64])
{
	gPC_1(tabin, temp);
	for (int i = 0; i < 16; i++)
	{
		gkey_f(temp, i, tabin);
		gprzypisz(tabin, temp);
		gPC_2(tabin, tabout[i]);
	}
}
char *dekodowanie(char *Text1, int arraySize)
{

	int total[64];
	int tabkey[64] =
	{
		0,1,0,1,0,1,1,1,
		0,0,1,1,0,1,0,0,
		0,1,0,1,0,1,1,1,
		0,1,1,1,1,0,0,1,
		0,1,0,1,0,1,1,1,
		1,0,1,1,1,1,0,0,
		0,1,0,1,0,1,1,1,
		1,1,1,1,0,0,0,1
	};
	int temp[64];
	int temp1[64];
	int tabr[64];
	int tabl[64];
	int keyss[16][64];

	int i, j, nB, m, iB, k, K, B[8], n, d;
	char *Text = new char[arraySize];
	unsigned char ch;
	Text = Text1;
	i = arraySize;
	keys(tabkey, keyss, temp);
	int mc = 0;

	char *final = new char[arraySize];

	for (iB = 0, nB = 0, m = 0; m<(arraySize / 8); m++) //Repeat for TextLenth/8 times.
	{
		for (iB = 0, i = 0; i<8; i++, nB++)
		{
			ch = Text[nB];
			n = abs((int)ch);//(int)Text[nB];
			for (K = 7; n >= 1; K--)
			{
				B[K] = n % 2;  //Converting 8-Bytes to 64-bit Binary Format
				n /= 2;
			}
			for (; K >= 0; K--) B[K] = 0;
			for (K = 0; K<8; K++, iB++) total[iB] = B[K]; //Now `total' contains the 64-Bit binary format of 8-Bytes
		}

		IP(total, temp);
		podzial(temp, tabl, tabr);//podzial tbr i tbl

		for (i = 15; i > -1; i--)
		{
			przypisz(tabr, temp1);
			funkcja_f(tabr, keyss[i], temp);

			xor (tabr, tabl, 32);
			przypisz(temp1, tabl);

		}
		polaczenie(total, tabr, tabl);
		IP_1(total, temp);

		k = 128;
		d = 0;
		for (i = 0; i<8; i++)
		{
			for (j = 0; j<8; j++)
			{
				d = d + temp[i * 8 + j] * k;
				k = k / 2;
			}
			final[mc++] = (char)d;
			k = 128;
			d = 0;
		}
	} //for loop ends here
	final[mc] = '\0';
	return(final);
}
char *kodowanie(char *Text1, int arraySize)
{

	int total[64];
	int tabkey[64] =
	{
		0,1,0,1,0,1,1,1,
		0,0,1,1,0,1,0,0,
		0,1,0,1,0,1,1,1,
		0,1,1,1,1,0,0,1,
		0,1,0,1,0,1,1,1,
		1,0,1,1,1,1,0,0,
		0,1,0,1,0,1,1,1,
		1,1,1,1,0,0,0,1
	};
	int temp[64];
	int temp1[64];
	int tabr[64];
	int tabl[64];
	int keyss[16][64];
	int i, a1, j, nB, m, iB, k, K, B[8], n, d;
	char *Text = new char[arraySize + 8];
	Text = Text1;
	i = arraySize;
	int mc = 0;
	a1 = i % 8;
	if (a1 != 0) for (j = 0; j<8 - a1; j++, i++) Text[i] = ' ';
	Text[i] = '\0';
	keys(tabkey, keyss, temp);

	arraySize = arraySize + a1;

	char *final = new char[arraySize];

	for (iB = 0, nB = 0, m = 0; m<(arraySize / 8); m++) //Repeat for TextLenth/8 times.
	{
		for (iB = 0, i = 0; i<8; i++, nB++)
		{
			n = (unsigned char)((int)Text[nB]);
			for (K = 7; n >= 1; K--)
			{
				B[K] = n % 2;  //Converting 8-Bytes to 64-bit Binary Format
				n /= 2;

			}
			for (; K >= 0; K--) B[K] = 0;
			for (K = 0; K<8; K++, iB++) total[iB] = B[K]; //Now `total' contains the 64-Bit binary format of 8-Bytes
		}

		IP(total, temp);
		podzial(temp, tabl, tabr);//podzial tbr i tbl

		for (i = 0; i < 16; i++)
		{
			przypisz(tabr, temp1);
			funkcja_f(tabr, keyss[i], temp);

			xor (tabr, tabl, 32);
			przypisz(temp1, tabl);

		}
		polaczenie(total, tabr, tabl);
		IP_1(total, temp);

		k = 128;
		d = 0;

		for (i = 0; i<8; i++)
		{
			for (j = 0; j<8; j++)
			{
				d = d + temp[i * 8 + j] * k;
				k = k / 2;
			}
			final[mc++] = (char)d;
			k = 128;
			d = 0;
		}
	} //for loop ends here

	final[mc] = '\0';
	return(final);
}
__global__ void kodowanie_gpu(char *obraz_in, char *obraz_out, int *dataSize)
{

	int arraySize = 48;
	int total[64];
	int tabkey[64] =
	{
		0,1,0,1,0,1,1,1,
		0,0,1,1,0,1,0,0,
		0,1,0,1,0,1,1,1,
		0,1,1,1,1,0,0,1,
		0,1,0,1,0,1,1,1,
		1,0,1,1,1,1,0,0,
		0,1,0,1,0,1,1,1,
		1,1,1,1,0,0,0,1
	};

	//int thread = blockIdx.x * blockDim.x + threadIdx.x;
	int temp[64];
	int temp1[64];
	int tabr[64];
	int tabl[64];
	int keyss[16][64];
	int  a1, j, nB, m, iB, k, K, B[8], n, d, i;
	//char *Text = new char[arraySize];
	/*
	for (int z = 0; z < arraySize; z++)
	{
	Text[z] = obraz_in[thread*arraySize + z];
	}

	int mc = thread * arraySize;
	keys(tabkey, keyss, temp);*/
	gkeys(tabkey, keyss, temp);
	int thread = ((blockIdx.x * blockDim.x + threadIdx.x));

	if (thread * arraySize > *dataSize)
		return;

	//int ii, a1, jj, nnB, mm, iiB, kk, KK, BB[8], nn, dd, roundround;
	char *Text = new char[arraySize];

	for (int haha = thread * arraySize, int ff = 0; haha < thread * arraySize + arraySize; haha++, ff++)
		Text[ff] = obraz_in[haha];

	i = arraySize;
	int mc = thread * arraySize;
	a1 = i % 8;

	char *final = new char[arraySize];

	for (iB = 0, nB = 0, m = 0; m<(arraySize / 8); m++) //Repeat for TextLenth/8 times.
	{
		for (iB = 0, i = 0; i<8; i++, nB++)
		{
			n = (unsigned char)((int)Text[nB]);
			for (K = 7; n >= 1; K--)
			{
				B[K] = n % 2;  //Converting 8-Bytes to 64-bit Binary Format
				n /= 2;

			}
			for (; K >= 0; K--) B[K] = 0;
			for (K = 0; K<8; K++, iB++) total[iB] = B[K]; //Now `total' contains the 64-Bit binary format of 8-Bytes
		}

		gIP(total, temp);
		gpodzial(temp, tabl, tabr);//podzial tbr i tbl

		for (i = 0; i < 16; i++)
		{
			gprzypisz(tabr, temp1);
			gfunkcja_f(tabr, keyss[i], temp);

			gxor(tabr, tabl, 32);
			gprzypisz(temp1, tabl);

		}
		gpolaczenie(total, tabr, tabl);
		gIP_1(total, temp);

		k = 128;
		d = 0;

		for (i = 0; i<8; i++)
		{
			for (j = 0; j<8; j++)
			{
				d = d + temp[i * 8 + j] * k;
				k = k / 2;
			}
			final[mc++] = (char)d;
			k = 128;
			d = 0;
		}
	} //for loop ends here */
}
char *CUDA1(int dataSize, char *bufor)
{
	int size = dataSize;
	int a1;
	int mc = 0;
	int j;
	a1 = size % 8;
	if (a1 != 0) for (j = 0; j<8 - a1; j++) bufor[j + size] = ' ';
	bufor[j + size] = '\0';
	size = size + a1;
	char *obraz_final;
	obraz_final = (char*)malloc((8 + size) * sizeof(char));

	int rozmiar = 64;
	int blocks = 64;
	int threads = 64;
	char *obraz_in, *obraz_out;
	char *d_obraz_in, *d_obraz_out;
	///////////////////////////////
	int mat_size = rozmiar * sizeof(char);
	int *roz = &size;
	//int *d_roz;
	////////////////////////////////////////////////////
	obraz_in = (char*)malloc(mat_size);
	obraz_out = (char*)malloc(mat_size);
	///////////////////////////////////////////////////////
	cudaMalloc(&d_obraz_in, mat_size);
	cudaMalloc(&d_obraz_out, mat_size);
	//cudaMalloc(&d_roz, sizeof(int));
	for (int i = 0; i <= size / rozmiar; i++)
	{
		for (int j = 0; j < rozmiar && j + i * rozmiar < size; j++) {
			obraz_in[j] = bufor[j + i * rozmiar];
		}


		////////////////////////////////////////////////////////////////////////////////
		cudaMemcpy(d_obraz_in, obraz_in, mat_size, cudaMemcpyHostToDevice);
		cudaMemcpy(d_obraz_out, obraz_in, mat_size, cudaMemcpyHostToDevice);
		//cudaMemcpy(d_roz, roz, sizeof(int), cudaMemcpyHostToDevice);

		//if (en_de) kodowanie_gpu << <blocks, threads>> >(d_obraz_in, d_obraz_out, rozmiar);
		//else dekodowanie_gpu << <blocks, threads >> >(dev_obraz_in, dev_obraz_out, dev_dataSize);

		cudaMemcpy(&obraz_out, d_obraz_out, mat_size, cudaMemcpyDeviceToHost);
		cout << obraz_out[65];
		for (int k = 0; k < rozmiar; k++);
		obraz_final[j + i * rozmiar] = obraz_out[j];
	}
	obraz_final[size + 7] = '\0';
	return obraz_final;
}
char *CUDA(int dataSize, char *bufor)
{
	char *obraz_final;
	obraz_final = (char*)malloc(dataSize * sizeof(char));

	int rozmiar = 1966080;

	clock_t startGPU = clock();

	for (int ii = 0; ii <= dataSize / rozmiar; ii++)
	{
		char *obraz_in;
		char *obraz_out;
		int *dataS;

		dataS = (int*)malloc(sizeof(int));
		dataS = &dataSize;

		obraz_in = (char*)malloc(dataSize * sizeof(char));
		obraz_out = (char*)malloc(dataSize * sizeof(char));

		char *dev_obraz_in;
		char *dev_obraz_out;
		int *dev_dataSize;

		for (auto i = ii * rozmiar, j = 0; (i <= (rozmiar + ii * rozmiar - 1)) & (i < dataSize); i += 1, j++)
			obraz_in[j] = bufor[i];

		cudaSetDevice(0);

		cudaMalloc((void**)&dev_obraz_in, dataSize * sizeof(char));
		cudaMalloc((void**)&dev_obraz_out, dataSize * sizeof(char));
		cudaMalloc((void**)&dev_dataSize, sizeof(int));

		cudaMemcpy(dev_obraz_in, obraz_in, dataSize * sizeof(char), cudaMemcpyHostToDevice);
		cudaMemcpy(dev_obraz_out, obraz_out, dataSize * sizeof(char), cudaMemcpyHostToDevice);
		cudaMemcpy(dev_dataSize, dataS, sizeof(int), cudaMemcpyHostToDevice);

		dim3 threads = 64;
		dim3 blocks = 640;

		kodowanie_gpu << <blocks, threads >> >(dev_obraz_in, dev_obraz_out, dev_dataSize);
		//else decrypt << <blocks, threads >> >(dev_obraz_in, dev_obraz_out, dev_dataSize);

		cudaDeviceSynchronize();
		cudaMemcpy(obraz_out, dev_obraz_out, dataSize * sizeof(char), cudaMemcpyDeviceToHost);

		cudaGetLastError();

		cudaDeviceReset();

		for (auto i = ii * rozmiar, j = 0; (i <= (rozmiar + ii * rozmiar - 1)) & (i < dataSize); i += 1, j++)
			obraz_final[i] = obraz_out[j];

		cudaFree(dev_obraz_in);
		cudaFree(dev_obraz_out);
		cudaFree(dev_dataSize);
		free(obraz_in);
		free(obraz_out);
	}
	printf("\nCzas wykonywania na GPU: %.4fs\n", (double)(clock() - startGPU) / CLOCKS_PER_SEC);

	return obraz_final;
}

int main()

{
	int arraySize;

	while (true)
	{
		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		printf("Kodowanie - 1     Dekodowanie - 0      Wyjscie - 2\nWybor: ");
		cin >> en_de;

		if (en_de == 2) break;

		printf("\nPlik wejsciowy: ");
		cin >> input;
		input.append(".bmp");

		printf("Zapis CPU:      ");
		cin >> obraz_cpu;
		obraz_cpu.append(".bmp");

		printf("Zapis GPU:      ");
		cin >> obraz_gpu;
		obraz_gpu.append(".bmp");

		printf("\nProces w toku:\n");

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		static constexpr size_t HEADER_SIZE = 54;

		ifstream bmp(input, ios::binary);

		ofstream output_cpu(obraz_cpu, ios::binary);

		array<char, HEADER_SIZE> header;
		bmp.read(header.data(), header.size());

		auto fileSize = *reinterpret_cast<uint32_t *>(&header[2]);
		auto dataOffset = *reinterpret_cast<uint32_t *>(&header[10]);
		auto width = *reinterpret_cast<uint32_t *>(&header[18]);
		auto height = *reinterpret_cast<uint32_t *>(&header[22]);
		auto depth = *reinterpret_cast<uint16_t *>(&header[28]);

		vector<char> img(dataOffset - HEADER_SIZE);
		bmp.read(img.data(), img.size());

		int dataSize = ((width * 3 + 3) & (~3)) * height;
		img.resize(dataSize + 1);
		bmp.read(img.data(), img.size());

		char *bufor = new char[dataSize + 1];

		// PRZYPISANIE DO BUFORA
		for (auto i = 0; i <= dataSize - 1; i += 1)
			bufor[i] = img[i];

		// CPU -----------------------
		char *img_output_cpu = new char[dataSize + 1];

		arraySize = dataSize;

		// KODOWANIE I DEKODOWANIE
		clock_t startCPU = clock();

		if (en_de == 1)img_output_cpu = kodowanie(bufor, arraySize);
		if (en_de == 0) img_output_cpu = dekodowanie(bufor, arraySize);

		printf("\nCzas wykonywania na CPU: %.4fs\n", (double)(clock() - startCPU) / CLOCKS_PER_SEC);

		for (int i = 0; i < header.size(); i++)
			output_cpu << header[i];

		for (auto i = 0; i <= dataSize - 1; i += 1)
			output_cpu << img_output_cpu[i];

		output_cpu.close();
		// GPU -----------------------
		char *img_output_gpu = new char[dataSize + 1];
		img_output_gpu = CUDA(arraySize, bufor);

		ofstream output_gpu(obraz_gpu, ios::binary);
		for (int i = 0; i < header.size(); i++)
			output_gpu << header[i];

		for (auto i = 0; i <= dataSize - 1; i += 1)
			output_gpu << img_output_gpu[i];

		output_gpu.close();

		printf("\nNacisnij, aby kontynuowac\n");
		cin.ignore();
		cin.get();

	}



	return 0;
}

