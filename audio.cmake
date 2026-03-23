set(AUDIO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/mupen64plus-audio-sdl")

find_package(SDL2)
find_package(PkgConfig)

pkg_check_modules(SPEEX speexdsp)
pkg_check_modules(SAMPLERATE samplerate)

add_library(audio)

target_include_directories(audio
PRIVATE
    ${AUDIO_DIR}/src
    ${CORE_DIR}/src/api
)

target_link_libraries(audio
PUBLIC
    SDL2::SDL2
    z
)

target_sources(audio
PRIVATE
	${AUDIO_DIR}/src/circular_buffer.c
	${AUDIO_DIR}/src/main.c
	${AUDIO_DIR}/src/sdl_backend.c
	${AUDIO_DIR}/src/volume.c
	${AUDIO_DIR}/src/resamplers/resamplers.c
	${AUDIO_DIR}/src/resamplers/trivial.c
)

if(${SPEEX_FOUND})
	message(NOTIFY "Using speex")
	target_sources(audio
	PRIVATE
		${AUDIO_DIR}/src/resamplers/speex.c
	)
	target_compile_definitions(audio
	PRIVATE
		USE_SPEEX
		${SPEEX_CFLAGS_OTHER}
	)
	target_link_libraries(audio
	PRIVATE
		${SPEEX_LIBRARIES}
	)
endif()

add_custom_command(
    TARGET audio POST_BUILD
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/redefine_syms.py -o ${CMAKE_OBJDUMP} -i $<TARGET_FILE_NAME:audio> -r ${PROJECT_BINARY_DIR}/audio_syms.txt -b audio_
    COMMAND ${CMAKE_OBJCOPY} --redefine-syms=${PROJECT_BINARY_DIR}/audio_syms.txt $<TARGET_FILE_NAME:audio>
)

add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/static_audio.cpp
    DEPENDS audio ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/gen_static_link.py
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/gen_static_link.py -o ${CMAKE_OBJDUMP} -i $<TARGET_FILE_NAME:audio> -c ${PROJECT_BINARY_DIR}/static_audio.cpp -b audio_
    VERBATIM
)

add_custom_target(static_audio_target
    DEPENDS ${PROJECT_BINARY_DIR}/static_audio.cpp
)
