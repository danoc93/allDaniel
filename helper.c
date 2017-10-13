#include <stdio.h>
#include <stdlib.h>
#include <sys/timeb.h>
#include "helper.h"

/**
 * Allocate a size = bytes amount of memory for array.
 */
void allocate_block(char **array, long bytes)
{
	*array = malloc(bytes);

	if(array == NULL)
	{
		report_error("Could not allocate any bytes.", -1);
	}
}

/**
* Return a FILE object opened in the desired mode (e.g. "w+").
*/
FILE* get_file(char* filepath, char* mode)
{
	FILE *fp;
	fp = fopen(filepath, mode);
	return fp;
}

/**
* Print an error and exit with the desired status.
*/
void report_error(char* error, int exit_code)
{
	printf("ERROR: %s\n", error);
	exit(exit_code);
}

/**
* Convert a string into a long integer.
*/
long int string_to_long(char* string)
{
	char* marker;
	return strtol(string, &marker, 10);
}

/**
* Return the current time in milliseconds. 
*/
long int get_current_time_in_ms()
{
	struct timeb t;
	ftime(&t);
	return t.time * 1000 + t.millitm;
}

/**
* Return the file size.
*/
long int get_file_size(FILE* file)
{
	fseek(file, 0L, SEEK_END);
	long int sz = ftell(file);
	rewind(file);
	return sz;
}