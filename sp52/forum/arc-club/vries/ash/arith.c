#include "arith.h"
#include "files.h"


/*
        Declare variables use for arithmetic compression
*/

static int under_flow_count = 0;
static unsigned int low = 0;
static unsigned int range = MAX_RANGE;
static unsigned int value = 0;

static unsigned int code_value = 0;
static unsigned int code_bit_count = 0;
static unsigned codesize = 0;


static int shift_count (unsigned);

static void put_bit (int);
static void put_bit_string (unsigned, int);
static void clear_under_flow (unsigned);

static unsigned get_bit_string (int);
static unsigned get_bit (void);



/*
        Initialize arithmetic coder at start of any compress/expand procedure
*/

void InitCoder (void)

{
        low = 0;
        range = MAX_RANGE;
}



/*
        Terminate arithmetic code operation
        Write bit string whose value is within active code range
        Force final byte to be output to file
*/

void CloseCoder (void)

{
        int i;

        put_bit (1);
        for (i = 0; i < 7; i++) put_bit (0);
        CloseOutputFile ();
}



/*
        Save state of arithmetic coder
        Allows state to be restored at a later time
*/

void SaveCoderState (struct coder_state *p)

{
        p -> low = low;
        p -> range = range;
        p -> uflow = under_flow_count;
        p -> bits = code_bit_count;
        p -> fpos = codesize;
}


/*
        Restore arithmetic coder state from saved value
        Repositin output file
        Set all internal values to their original state
*/

void RestoreCoderState (struct coder_state *p)

{
        int n;
        int cv;
        static unsigned char reset_mask [] =

        {
                0x00,  0x80,  0xC0,  0xE0,  0xF0,  0xF8,  0xFC,  0xFE,  0xFF,
        };

        n = codesize - p -> fpos;
        cv = ResetOutputPointer (n);

        low = p -> low;
        range = p -> range;

        under_flow_count = p -> uflow;
        code_bit_count = p -> bits;
        code_value = cv & reset_mask [code_bit_count];
        codesize -= n;
}


/*
        Estimate length of output code string
        Uses previously saved coder state
        Returns difference between saved position and current position
*/

int CodeLength (struct coder_state *csptr)

{
        int len;

        len = codesize - csptr -> fpos;
        len *= 8;
        len += under_flow_count - csptr -> uflow;
        len += code_bit_count - csptr -> bits;

        return len;
}


/*
        Arithmetic coder
        Encode symbol using input frequencies
        Output as many bits as possible to output file
        Update coder values for next symbol
*/

void EncodeArith (unsigned base, unsigned freq, unsigned cmax)

{
        unsigned long t;
        unsigned x;

        int n1, n2;

        t  = (long) range * (long) base;
        t += (long) base;
        low  += (unsigned) (t / cmax);
        x     = (unsigned) (t % cmax);

        t = (long) range * (long) freq;

        t += (long) (freq + x);
        t -= cmax;
        range = (unsigned) (t / cmax);

        n1 = shift_count ((low + range) ^ low);
        if (n1 && under_flow_count)
        {
                clear_under_flow ((low & 0x8000) != 0);
                low ^= 0x8000;
        }

        if (n1)
        {
                put_bit_string (low, n1);
                low <<= n1;
                range = ((range + 1) << n1) - 1;
        }

        if (range < MIN_RANGE)
        {
                n2 = shift_count (range - 1) - 1;

                under_flow_count += n2;
                low <<= n2;
                low &= 0x7FFF;
                range = ((range + 1) << n2) - 1;
        }
}


/*
        Send bit string based on underflow count
        Uses bit value followed by its complement

        generates: 0111... or 1000...
*/
        
static void clear_under_flow (unsigned bit)

{
        put_bit (bit);
        bit ^= 0x01;
        while (-- under_flow_count) put_bit (bit);
}



/*
        Send bit string
*/

static void put_bit_string (unsigned x, int count)

{
        while (count)
        {
                put_bit ((x & 0x8000) != 0);
                x <<= 1;
                count --;
        }
}



/*
        Write single bit to output file using internal buffer
*/

static void put_bit (int bit)

{
        static unsigned char mask [] =
        {
                0x80,   0x40,   0x20,   0x10,   0x08,   0x04,   0x02,   0x01,
        };

        if (bit) code_value |= mask [code_bit_count];
        if (++ code_bit_count == 8)
        {
                WriteOutputFile (code_value);
                code_value = 0;
                code_bit_count = 0;
                codesize ++;
        }
}



/*
        Determine number of leading zero bits on unsigned value
*/

static int shift_count (unsigned n)

{
        int i;

        i = 0;
        while ((n & 0x8000) == 0 && i < 16)
        {
                i ++;
                n <<= 1;
        }

        return i;
}



/*
        Read bit string from input stream
        Length is limited to word size
*/

static unsigned get_bit_string (int n)

{
        unsigned x = 0;

        while (n)
        {
                x <<= 1;
                x += get_bit ();
                n --;
        }

        return x;
}



/*
        Read a single bit from input stream
        Uses a one byte buffer for intermediate values
*/

static unsigned get_bit (void)

{
        int n;

        if (code_bit_count == 0)
        {
                code_bit_count = 8;
                n = ReadInputFile ();
                code_value = n >= 0 ? n : 0;
        }

        code_bit_count --;
        n = code_value & 0x80;
        code_value <<= 1;

        return n != 0;
}



/*
        Initialize arithmetic decode procedure
*/

void StartDecode (void)

{
        int i;

        value = 0;
        for (i = 0; i < 16; i ++)
        {
                value <<= 1;
                value |= get_bit ();
        }
}


/*
        Return value of next input code
        Input consists of total frequency for active symbol set
        Note that decoder must be updated with actual frequencies used
*/

int DecodeArith (unsigned cmax)

{
        unsigned long t;

        t = (long) (value - low + 1) * (long) cmax;
        t -= 1;
        t /= (long) range + 1;

        return (unsigned) t;
}


/*
        Update arithmetic decoder using actual symbol frequencies
        Read additional bits from input based on symbol values
*/

void UpdateDecoder (unsigned base, unsigned freq, unsigned cmax)

{
        unsigned long t;
        unsigned x, y;

        int n1, n2;

        t  = (long) range * (long) base;
        t += (long) base;
        x  = (unsigned) (t / cmax);
        y  = (unsigned) (t % cmax);

        low += x;

        t = (long) range * (long) freq;
        t += (long) (freq + y);
        t -= cmax;
        range = (unsigned) (t / cmax);

        n1 = shift_count ((low + range) ^ low);
        if (n1)
        {
                low <<= n1;
                range = ((range + 1) << n1) - 1;
                value <<= n1;
                value |= get_bit_string (n1);
        }

        if (range < MIN_RANGE)
        {
                n2 = shift_count (range - 1) - 1;
                value -= low;
                low <<= n2;
                low &= 0x7FFF;
                range = ((range + 1) << n2) - 1;
                value <<= n2;
                value |= get_bit_string (n2);
                value += low;
        }
}
