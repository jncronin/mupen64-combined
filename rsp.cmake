set(RSP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/mupen64plus-rsp-hle")

find_package(SDL2)

add_library(rsp)

target_include_directories(rsp
PRIVATE
    ${RSP_DIR}/src
    ${CORE_DIR}/src/api
)

target_link_libraries(rsp
PUBLIC
    GL
    SDL2::SDL2
    z
)

target_sources(rsp
PRIVATE
	${RSP_DIR}/src/alist.c
	${RSP_DIR}/src/alist_audio.c
	${RSP_DIR}/src/alist_naudio.c
	${RSP_DIR}/src/alist_nead.c
	${RSP_DIR}/src/audio.c
	${RSP_DIR}/src/cicx105.c
	${RSP_DIR}/src/hle.c
	${RSP_DIR}/src/hvqm.c
	${RSP_DIR}/src/jpeg.c
	${RSP_DIR}/src/memory.c
	${RSP_DIR}/src/mp3.c
	${RSP_DIR}/src/musyx.c
	${RSP_DIR}/src/re2.c
	${RSP_DIR}/src/plugin.c
)

add_custom_command(
    TARGET rsp POST_BUILD
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/redefine_syms.py -o ${CMAKE_OBJDUMP} -i $<TARGET_FILE_NAME:rsp> -r ${PROJECT_BINARY_DIR}/rsp_syms.txt -b rsp_
    COMMAND ${CMAKE_OBJCOPY} --redefine-syms=${PROJECT_BINARY_DIR}/rsp_syms.txt $<TARGET_FILE_NAME:rsp>
)

add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/static_rsp.cpp
    DEPENDS rsp ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/gen_static_link.py
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/gen_static_link.py -o ${CMAKE_OBJDUMP} -i $<TARGET_FILE_NAME:rsp> -c ${PROJECT_BINARY_DIR}/static_rsp.cpp -b rsp_
    VERBATIM
)

add_custom_target(static_rsp_target
    DEPENDS ${PROJECT_BINARY_DIR}/static_rsp.cpp
)
