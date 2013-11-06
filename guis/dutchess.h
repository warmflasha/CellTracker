/*
 * MATLAB Compiler: 4.17 (R2012a)
 * Date: Wed Aug 15 13:15:31 2012
 * Arguments: "-B" "macro_default" "-C" "-l" "dutchess.m" 
 */

#ifndef __dutchess_h
#define __dutchess_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

#if defined(__SUNPRO_CC)
/* Solaris shared libraries use __global, rather than mapfiles
 * to define the API exported from a shared library. __global is
 * only necessary when building the library -- files including
 * this header file to use the library do not need the __global
 * declaration; hence the EXPORTING_<library> logic.
 */

#ifdef EXPORTING_dutchess
#define PUBLIC_dutchess_C_API __global
#else
#define PUBLIC_dutchess_C_API /* No import statement needed. */
#endif

#define LIB_dutchess_C_API PUBLIC_dutchess_C_API

#elif defined(_HPUX_SOURCE)

#ifdef EXPORTING_dutchess
#define PUBLIC_dutchess_C_API __declspec(dllexport)
#else
#define PUBLIC_dutchess_C_API __declspec(dllimport)
#endif

#define LIB_dutchess_C_API PUBLIC_dutchess_C_API


#else

#define LIB_dutchess_C_API

#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_dutchess_C_API 
#define LIB_dutchess_C_API /* No special import/export declaration */
#endif

extern LIB_dutchess_C_API 
bool MW_CALL_CONV dutchessInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_dutchess_C_API 
bool MW_CALL_CONV dutchessInitialize(void);

extern LIB_dutchess_C_API 
void MW_CALL_CONV dutchessTerminate(void);



extern LIB_dutchess_C_API 
void MW_CALL_CONV dutchessPrintStackTrace(void);

extern LIB_dutchess_C_API 
bool MW_CALL_CONV mlxDutchess(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);



extern LIB_dutchess_C_API bool MW_CALL_CONV mlfDutchess(int nargout, mxArray** varargout, mxArray* varargin);

#ifdef __cplusplus
}
#endif
#endif
