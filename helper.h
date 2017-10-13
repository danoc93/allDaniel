/** Function definitions **/
void allocate_block(char **array, long bytes);
FILE* get_file(char* filepath, char* mode);
void report_error(char *array, int exit_code);
long int string_to_long(char* string);
long int get_current_time_in_ms();
long int get_file_size(FILE* file);