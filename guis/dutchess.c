/*
 * MATLAB Compiler: 4.17 (R2012a)
 * Date: Wed Aug 15 13:15:31 2012
 * Arguments: "-B" "macro_default" "-C" "-l" "dutchess.m" 
 */

#include <stdio.h>
#define EXPORTING_dutchess 1
#include "dutchess.h"

static HMCRINSTANCE _mcr_inst = NULL;


#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_dutchess_C_API
#define LIB_dutchess_C_API /* No special import/export declaration */
#endif

LIB_dutchess_C_API 
bool MW_CALL_CONV dutchessInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler)
{
    int bResult = 0;
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
    bResult = mclInitializeComponentInstanceNonEmbeddedStandalone(  &_mcr_inst,
                                                                    NULL,
                                                                    "dutchess",
                                                                    LibTarget,
                                                                    error_handler, 
                                                                    print_handler);
    if (!bResult)
    return false;
  return true;
}

LIB_dutchess_C_API 
bool MW_CALL_CONV dutchessInitialize(void)
{
  return dutchessInitializeWithHandlers(mclDefaultErrorHandler, mclDefaultPrintHandler);
}

LIB_dutchess_C_API 
void MW_CALL_CONV dutchessTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

LIB_dutchess_C_API 
void MW_CALL_CONV dutchessPrintStackTrace(void) 
{
  char** stackTrace;
  int stackDepth = mclGetStackTrace(&stackTrace);
  int i;
  for(i=0; i<stackDepth; i++)
  {
    mclWrite(2 /* stderr */, stackTrace[i], sizeof(char)*strlen(stackTrace[i]));
    mclWrite(2 /* stderr */, "\n", sizeof(char)*strlen("\n"));
  }
  mclFreeStackTrace(&stackTrace, stackDepth);
}


LIB_dutchess_C_API 
bool MW_CALL_CONV mlxDutchess(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "dutchess", nlhs, plhs, nrhs, prhs);
}

LIB_dutchess_C_API 
bool MW_CALL_CONV mlfDutchess(int nargout, mxArray** varargout, mxArray* varargin)
{
  return mclMlfFeval(_mcr_inst, "dutchess", nargout, -1, -1, varargout, varargin);
}

