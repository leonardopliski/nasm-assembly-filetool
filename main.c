#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

// Protótipos
// Função para comprimir um determinado arquivo de entrada para um arquivo de saída.
int comprime(int fd_entrada, int fd_saida);
// Função para descomprimir um arquivo comprimido de entradaa para um arquivo descomprimido de saída.
int descomprime(int fd_entrada, int fd_saida); 

int main (int argc, char *argv[]) {

    if(argc < 4 || argc > 4){
    	printf("Use: \n./filetool -c input_file.txt output_result.txt to compress.\n./filetool -d compressed_file.txt decompressed_file.txt to decompress.\n");
    	return 0;
    }

    // Compressão
    if (strcmp(argv[1],"-c") == 0) {

    	// Arquivos de entrada e saída
    	char *arquivo_entrada = argv[2];
    	char *arquivo_saida   = argv[3];

		// compressão
		// gera o file descriptor para o arquivo de entrada com a flag read only
		int fd_entrada = open(arquivo_entrada, O_RDONLY | O_CREAT, 0777);

		// gera o file descriptor para o arquivo de saída com a flag read/write
		int fd_saida   = open(arquivo_saida, O_RDWR | O_CREAT, 0777);

		// verificação de erros na leitura/escrita arquivos
		if (fd_entrada == -1) {
			printf("Error! cannot read or create input file, try again with another file.\n");
			return -1;
		}else if (fd_saida == -1) {
			printf("Error! cannot read/write or create output file, try again with another file.\n");
			return -1;
		}

		int resultado =  comprime(fd_entrada,fd_saida);

		if(resultado == 0){
			printf("Successful compression\n");
			printf("Output file: '%s'\n", arquivo_saida);
		} else {
			printf("Error! failure at compression, verify your input and output file.\n");
		}

	} else if (strcmp(argv[1],"-d") == 0) { // Instrução para descompressão

    		// Arquivos de entrada e saída
			char *arquivo_entrada = argv[2];
    		char *arquivo_saida   = argv[3];

			// Gera o file descriptor para o arquivo de entrada com a flag read only
			int fd_entrada = open(arquivo_entrada, O_RDONLY | O_CREAT, 0777);

			// Gera o file descriptor para o arquivo de saída com a flag read/write
			int fd_saida   = open(arquivo_saida, O_RDWR | O_CREAT, 0777);

			// verificação de erros na leitura/escrita arquivos
			if (fd_entrada == -1) {
				printf("Error! cannot read or create input file, try again with another file.\n");
				return -1;
			}else if (fd_saida == -1) {
				printf("Error! cannot read/write or create output file, try again with another file.\n");
				return -1;
			}

			int resultado =  descomprime(fd_entrada,fd_saida);

			if(resultado == 0){
				printf("Successful decompression\n");
				printf("Output file: '%s'\n", arquivo_saida);
			} else {
				printf("Error! failure at decompression, verify your input and output file.\n");
			}

    } else {
    	printf("Use: \n./filetool -c input_file.txt output_result.txt to compress.\n./filetool -d compressed_file.txt decompressed_file.txt to decompress.\n");
    	return 0;
    }

	return 0;
}