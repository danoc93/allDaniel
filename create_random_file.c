#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "create_random_file.h"
#include "helper.h"
#include <strings.h>

/**
 * Populate a size = bytes allocated array.
 * Use random characters from A to Z.
 */
void random_array(char *array, long bytes)
{
	if(!array || bytes <= 0)
	{
		report_error("The array is not allocated. Cannot populate.", -1);
	}

	srand ( time(NULL) );
	for (int i = 0; i < bytes; i++)
	{
		//ASCII codes go from 65 to 90.
		array[i] = 65 + (rand() % 26);
	}
}

/*
Algorithm:
 * Create a buffer of size BLOCK_SIZE [bytes].
 * Fill it with BLOCK_SIZE random characters.
 * Write min(bytes left to write, BLOCK_SIZE) of the buffer data to FILE_PATH.
 * Create a file and track how many bytes you've written.
 * Report the time it took to perform all the writing operations.
*/
int main(int argc, char** argv)
{

	if (argc != 4) 
	{
  		report_error("Expected <filepath>, <size [b]>, <block size [b]>.", -1);
	}

	char* FILE_PATH = argv[1];
	long int TOTAL_BYTES = string_to_long(argv[2]);
	long int BLOCK_SIZE = string_to_long(argv[3]);

	if(TOTAL_BYTES < 1 || BLOCK_SIZE < 1)
	{
		report_error("Invalid argument values.", -1);
	}


	/* BEGIN */

	FILE* fileToWrite = get_file(FILE_PATH, "w+");

	//Helper variables.
	char *buffer;
	long int bytesToWrite;
	long int bytesWritten;
	int healthy = 1;

	//Trackers.
	long int totalbytesleft = TOTAL_BYTES;
	long int startTime = get_current_time_in_ms();

	allocate_block(&buffer, BLOCK_SIZE);

	while(totalbytesleft > 0 && healthy)
	{
		//Clean and re-populate random buffer.
		bzero(buffer, BLOCK_SIZE);
		random_array(buffer, BLOCK_SIZE);

		bytesToWrite = 
			(totalbytesleft > BLOCK_SIZE) ? BLOCK_SIZE : totalbytesleft;

		bytesWritten = fwrite(buffer, 1, bytesToWrite, fileToWrite);
		fflush(fileToWrite);
		healthy = bytesWritten > 0;

		totalbytesleft = totalbytesleft - bytesToWrite;
	}

	free(buffer);
	fclose(fileToWrite);
	
	if(!healthy)
	{
		report_error("A problem was found while writting to the file.", -1);
	}
	
	long int endTime = get_current_time_in_ms();

	printf("Time elapsed: %ld ms.\n", endTime - startTime);

	/* END */

    return 0;
}