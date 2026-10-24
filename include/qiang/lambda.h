#ifndef __QPCC_QBE_LAMBDA_H
#define __QPCC_QBE_LAMBDA_H

/*
 * QPCC <lambda.h>: the friendly spellings for the closure keywords.
 *
 *   auto f = lambda(a, &b) int (int x) { return a + *b + x; };
 *   int *pb = closure_environment(f)->b;
 *
 * A _Lambda expression builds a { function, environment } pair. The
 * environment is a local of the enclosing function, so a closure that
 * outlives the scope it was created in is undefined behaviour.
 */
#define lambda _Lambda
#define closure_environment _Closure_environment

#endif /* __QPCC_QBE_LAMBDA_H */
