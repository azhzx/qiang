#ifndef __QPCC_QBE_FUNCTION_POINTER_H
#define __QPCC_QBE_FUNCTION_POINTER_H

/*
 * QPCC <function_pointer.h>: the friendly spelling for _Function_pointer,
 * the C2y prefix form of a function pointer type plus the storage type for
 * any function pointer (N3914's _Any_func*).
 *
 *   function_pointer int (int, char *) a;   --  int (*a)(int, char *)
 *   function_pointer a;                     --  stores any function pointer
 *
 * A bare function_pointer is not callable: cast it to a concrete function
 * pointer type first, the same way N3914 requires for _Any_func*.
 */
#define function_pointer _Function_pointer

#endif /* __QPCC_QBE_FUNCTION_POINTER_H */
