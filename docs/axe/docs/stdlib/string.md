# .\string.axec

## model string

string model representing a dynamic string with length tracking.

## def create(data: char*): string

Creates a new string from a char pointer.

## def create_with_capacity(arena: char*, capacity: i32): string

Creates a new empty string with specified capacity.

## def str_len(s: string): usize

Returns the length of a string.

## def to_title_case(s: string): string

Convert some string to titlecase.

## def to_upper(s: string): string

Converts string to uppercase.

## def to_lower(s: string): string

Converts string to lowercase.

## def str_copy(src: string, desta: mut string): void

Copies source string to destination. Modifies dest in place.

## def compare(a: string, b: string): i32

Compares two strings. Returns 0 if equal.

## def concat(dest: string, src: string): string

Concatenates source string to destination. Returns a new string.

## def first_occurrence(s: string, c: i32): char*

Finds first occurrence of character in string. Returns pointer or 0.

## def substring(haystack: string, needle: string): char*

Finds first occurrence of substring in string. Returns pointer or 0.

## def str_to_int(s: string): i32

Converts string to integer.

## def str_to_long(s: char*): i64

Converts string to long integer.

## def is_alpha(c: i32): i32

Checks if character is alphabetic.

## def is_digit(c: i32): i32

Checks if character is numeric.

## def is_alnum(c: i32): i32

Checks if character is alphanumeric.

## def to_upper_chrptr(s: char*): char*

Converts char* to uppercase.

## def to_lower_chrptr(s: char*): char*

Converts char* to lowercase.

## def to_upper_chr(c: i32): i32

Converts character to uppercase.

## def to_lower_chr(c: i32): i32

Converts character to lowercase.

## def str_dup(s: char*): char*

Allocates and copies a string. Caller must free the result.

## def str_ncmp(s1: char*, s2: char*, n: i32): i32

Compares first n characters of two strings. Returns 0 if equal.

## def str_ncopy(dest: char*, src: char*, n: i32): char*

Copies at most n characters from source to destination.

## def int_to_str(value: i32, buffer: char*): char*

Converts an integer to a string. Buffer must be at least 12 bytes.

## def long_to_str(value: i64, buffer: char*): char*

Converts a long to a string. Buffer must be at least 21 bytes.

## def float_to_str(value: f32, buffer: char*): char*

Converts a float to a string. Buffer must be at least 32 bytes.

## def double_to_str(value: f64, buffer: char*): char*

Converts a double to a string. Buffer must be at least 32 bytes.

## def fmt(fmt_string: string, args: string[]): string

Formats a string using a format string and arguments.
Each `{}` placeholder in `fmt_string` is replaced by the next string in `args`.


## def find_char_from(s: string, c: char, start: usize): i32

Returns the index of the first occurrence of character `c` in `s` at or after `start`.
Returns -1 if the character is not found.


## def substr(s: string, start: usize, length: usize): string

Returns a substring of `s` starting at `start` with the given `length`.
If `start` is beyond the end of the string or `length` is zero, an empty string is returned.
The function clamps the requested range to the bounds of the source string.


## def has_prefix(s: string, prefix: string): bool

Checks if string has prefix.

## def has_suffix(s: string, suffix: string): bool

Checks if string has suffix.

## def trim_prefix(s: string, prefix: string): string

Removes prefix from string.

## def trim_suffix(s: string, suffix: string): string

Removes suffix from string.

## def lstrip(s: string): string

Strip leading whitespace from a string.

## def rstrip(s: string): string

Strip trailing whitespace from a string.

## def strip(s: string): string

String trailing and leading whitespace.
