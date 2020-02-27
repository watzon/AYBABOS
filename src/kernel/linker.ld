/* The bootloader will look at this image and start execution at the symbol
   designated as the entry point. */
ENTRY(_start)
 
/* Tell where the various sections of the object files will be put in the final
   kernel image. */
SECTIONS
{
	/* Begin putting sections at 1 MiB, a conventional place for kernels to be
	   loaded at by the bootloader. */
	. = 1M;
 
    start_of_kernel_image = .;

	/* First put the multiboot header, as it is required to be put very early
	   early in the image or the bootloader won't recognize the file format.
	   Next we'll put the .text section. */
	.text : ALIGN(4K)
	{
		KEEP(*(.multiboot))
        start_of_kernel_text = .;
		*(.text)
        end_of_kernel_text = .;
	}
 
	/* Read-only data. */
	.rodata : ALIGN(4K)
	{
        start_ctors = .;
        *(.ctors)
        end_ctors = .;

		*(.rodata)
	}
 
	/* Read-write data (initialized) */
	.data : ALIGN(4K)
	{
		start_of_kernel_data = .;
        *(.data)
        end_of_kernel_data = .;
	}
 
	/* Read-write data (uninitialized) and stack */
	.bss : ALIGN(4K)
	{
		start_of_kernel_bss = .;
        *(page_tables)
        *(COMMON)
        *(.bss)
        end_of_kernel_bss = .;
	}
 
	end_of_kernel_image = .;
}