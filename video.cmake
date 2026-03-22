set(VIDEO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/mupen64plus-video-rice")

find_package(SDL2)

add_library(video)

target_include_directories(video
PRIVATE
    ${VIDEO_DIR}/src
    ${CORE_DIR}/src/api
)

target_link_libraries(video
PUBLIC
    GL
    SDL2::SDL2
    z
)

target_sources(video
PRIVATE
	${VIDEO_DIR}/src/liblinux/BMGImage.c
	${VIDEO_DIR}/src/liblinux/BMGUtils.c
	${VIDEO_DIR}/src/liblinux/bmp.c
	${VIDEO_DIR}/src/liblinux/pngrw.c
	${VIDEO_DIR}/src/Blender.cpp
	${VIDEO_DIR}/src/Combiner.cpp
	${VIDEO_DIR}/src/Config.cpp
	${VIDEO_DIR}/src/ConvertImage.cpp
	${VIDEO_DIR}/src/ConvertImage16.cpp
	${VIDEO_DIR}/src/Debugger.cpp
	${VIDEO_DIR}/src/DeviceBuilder.cpp
	${VIDEO_DIR}/src/FrameBuffer.cpp
	${VIDEO_DIR}/src/GraphicsContext.cpp
	${VIDEO_DIR}/src/OGLCombiner.cpp
	${VIDEO_DIR}/src/OGLExtensions.cpp
	${VIDEO_DIR}/src/OGLGraphicsContext.cpp
	${VIDEO_DIR}/src/OGLRender.cpp
	${VIDEO_DIR}/src/OGLRenderExt.cpp
	${VIDEO_DIR}/src/OGLTexture.cpp
	${VIDEO_DIR}/src/Render.cpp
	${VIDEO_DIR}/src/RenderBase.cpp
	${VIDEO_DIR}/src/RenderExt.cpp
	${VIDEO_DIR}/src/RenderTexture.cpp
	${VIDEO_DIR}/src/RSP_Parser.cpp
	${VIDEO_DIR}/src/RSP_S2DEX.cpp
	${VIDEO_DIR}/src/Texture.cpp
	${VIDEO_DIR}/src/TextureFilters.cpp
	${VIDEO_DIR}/src/TextureFilters_2xsai.cpp
	${VIDEO_DIR}/src/TextureFilters_hq2x.cpp
	${VIDEO_DIR}/src/TextureFilters_hq4x.cpp
	${VIDEO_DIR}/src/TextureManager.cpp
	${VIDEO_DIR}/src/VectorMath.cpp
	${VIDEO_DIR}/src/Video.cpp

    ${VIDEO_DIR}/src/osal_files_unix.c
)

set(NO_ASM 1)
if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86")
	set(NO_ASM 0)
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
	set(NO_ASM 0)
endif()

if(${NO_ASM} EQUAL 1)
	target_compile_definitions(video PRIVATE NO_ASM=1)
endif()

add_custom_command(
    TARGET video POST_BUILD
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/redefine_syms.py -o ${CMAKE_OBJDUMP} -i $<TARGET_FILE_NAME:video> -r ${PROJECT_BINARY_DIR}/video_syms.txt -b video_
    COMMAND ${CMAKE_OBJCOPY} --redefine-syms=${PROJECT_BINARY_DIR}/video_syms.txt $<TARGET_FILE_NAME:video>
)

add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/static_video.cpp
    DEPENDS video ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/gen_static_link.py
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/gen_static_link.py -o ${CMAKE_OBJDUMP} -i $<TARGET_FILE_NAME:video> -c ${PROJECT_BINARY_DIR}/static_video.cpp -b video_
    VERBATIM
)

add_custom_target(static_video_target
    DEPENDS ${PROJECT_BINARY_DIR}/static_video.cpp
)
