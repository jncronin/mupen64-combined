extern "C" {
    #include "osal_dynamiclib.h"
    #include "osal_files.h"
}

#include "core_interface.h"
#include "m64p_common.h"

extern "C"
{
    void *core_getproc(const char *name);
    void *video_getproc(const char *name);
    void *rsp_getproc(const char *name);
    void *audio_getproc(const char *name);
    void *input_getproc(const char *name);
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
#define LIB_AUDIO   (0xad10)

/* return a static list of modules */
static const osal_lib_search mod_input
{
    .filepath = "input.mod",
    .filename = (char *)"input.mod",
    .plugin_type = M64PLUGIN_INPUT,
    .next = nullptr
};

static const osal_lib_search mod_audio
{
    .filepath = "audio.mod",
    .filename = (char *)"audio.mod",
    .plugin_type = M64PLUGIN_AUDIO,
    .next = (osal_lib_search *)&mod_input
};

static const osal_lib_search mod_rsp
{
    .filepath = "rsp.mod",
    .filename = (char *)"rsp.mod",
    .plugin_type = M64PLUGIN_RSP,
    .next = (osal_lib_search *)&mod_audio
};

static const osal_lib_search mod_video
{
    .filepath = "video.mod",
    .filename = (char *)"video.mod",
    .plugin_type = M64PLUGIN_GFX,
    .next = (osal_lib_search *)&mod_rsp,
};

static const osal_lib_search mod_core
{
    .filepath = "libmupen64plus.so.2",
    .filename = (char *)"libmupen64plus.so.2",
    .plugin_type = M64PLUGIN_CORE,
    .next = (osal_lib_search *)&mod_video,
};

m64p_error osal_dynlib_open(m64p_dynlib_handle *pLibHandle, const char *pccLibraryPath)
{
    if(strcmp("libmupen64plus.so.2", pccLibraryPath) == 0)
    {
        *pLibHandle = (m64p_dynlib_handle)LIB_CORE;
        return M64ERR_SUCCESS;
    }
    else if(strcmp("video.mod", pccLibraryPath) == 0)
    {
        *pLibHandle = (m64p_dynlib_handle)LIB_VIDEO;
        return M64ERR_SUCCESS;
    }
    else if(strcmp("rsp.mod", pccLibraryPath) == 0)
    {
        *pLibHandle = (m64p_dynlib_handle)LIB_RSP;
        return M64ERR_SUCCESS;
    }
    else if(strcmp("audio.mod", pccLibraryPath) == 0)
    {
        *pLibHandle = (m64p_dynlib_handle)LIB_AUDIO;
        return M64ERR_SUCCESS;
    }
    else if(strcmp("input.mod", pccLibraryPath) == 0)
    {
        *pLibHandle = (m64p_dynlib_handle)LIB_INPUT;
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
        case LIB_VIDEO:
            return video_getproc(pccProcedureName);
        case LIB_RSP:
            return rsp_getproc(pccProcedureName);
        case LIB_AUDIO:
            return audio_getproc(pccProcedureName);
        case LIB_INPUT:
            return input_getproc(pccProcedureName);
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
    return (osal_lib_search *)&mod_core;
}

void             osal_free_lib_list(osal_lib_search *head)
{
    fprintf(stderr, "OSAL_FREE_LIB_LIST\n");
}
