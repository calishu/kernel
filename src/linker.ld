ENTRY(_start)

PHDRS
{
    headers PT_PHDR PHDRS ;
    text    PT_LOAD FILEHDR PHDRS ;
    data    PT_LOAD ;
}

SECTIONS
{
    /* Start at the Higher Half */
    . = 0xffffffff80000000;

    /* The ELF headers must be mapped here to satisfy Limine */
    .text : {
        *(.text .text.*)
    } :text

    .rodata : {
        *(.rodata .rodata.*)
    } :text

    /* Move to the next page to separate code from data */
    . = ALIGN(0x1000);

    .data : {
        *(.data .data.*)
    } :data

    .requests : {
        KEEP(*(.requests))
        *(.requests.*)
    } :data

    .bss : {
        *(.bss .bss.*)
        *(COMMON)
    } :data

    /* Throw away things we don't need */
    /DISCARD/ : {
        *(.interp)
        *(.note .note.*)
    }
}
