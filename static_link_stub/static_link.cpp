extern "C" {
    #include "osal_dynamiclib.h"
    #include "osal_files.h"
}

#include "core_interface.h"
#include "m64p_common.h"

extern "C"
{
    void *core_getproc(const char *name);
}

#include <cstdio>
#include <cstring>

const int   osal_libsearchdirs = 0;
const char *osal_libsearchpath[] = { nullptr };

/* magic values to identify the modules */
#define LIB_CORE    (0xc00e)
#define LIB_VIDEO   (0x1de0)
#define LIB_RSP     (0x0acc)
#define LIB_INPUT   (0x1111)

m64p_error osal_dynlib_open(m64p_dynlib_handle *pLibHandle, const char *pccLibraryPath)
{
    if(strcmp("libmupen64plus.so.2", pccLibraryPath) == 0)
    {
        *pLibHandle = (m64p_dynlib_handle)LIB_CORE;
        return M64ERR_SUCCESS;
    }
    fprintf(stderr, "OSAL_DYNLIB_OPEN: %s\n", pccLibraryPath);
    return M64ERR_SYSTEM_FAIL;
}

void *     osal_dynlib_getproc(m64p_dynlib_handle LibHandle, const char *pccProcedureName)
{
    switch((uintptr_t)LibHandle)
    {
        case LIB_CORE:
            return core_getproc(pccProcedureName);
    }
    fprintf(stderr, "OSAL_DYNLIB_GETPROC: %s\n", pccProcedureName);
    return nullptr;
}

m64p_error osal_dynlib_close(m64p_dynlib_handle LibHandle)
{
    fprintf(stderr, "OSAL_DYNLIB_CLOSE\n");
    return M64ERR_SUCCESS;
}

osal_lib_search *osal_library_search(const char *searchpath)
{
    fprintf(stderr, "OSAL_LIBRARY_SEARCH: %s\n", searchpath);
    return nullptr;
}

void             osal_free_lib_list(osal_lib_search *head)
{
    fprintf(stderr, "OSAL_FREE_LIB_LIST\n");
}
