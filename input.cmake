set(INPUT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/mupen64plus-input-sdl")

find_package(SDL2)

add_library(input)

target_include_directories(input
PRIVATE
    ${INPUT_DIR}/src
    ${CORE_DIR}/src/api
)

target_link_libraries(input
PUBLIC
    SDL2::SDL2
    z
)

target_sources(input
PRIVATE
	${INPUT_DIR}/src/plugin.c
	${INPUT_DIR}/src/autoconfig.c
	${INPUT_DIR}/src/sdl_key_converter.c
	${INPUT_DIR}/src/config.c
)

add_custom_command(
    TARGET input POST_BUILD
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/redefine_syms.py -o ${CMAKE_OBJDUMP} -i $<TARGET_FILE_NAME:input> -r ${PROJECT_BINARY_DIR}/input_syms.txt -b input_
    COMMAND ${CMAKE_OBJCOPY} --redefine-syms=${PROJECT_BINARY_DIR}/input_syms.txt $<TARGET_FILE_NAME:input>
)

add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/static_input.cpp
    DEPENDS input ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/gen_static_link.py
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/gen_static_link.py -o ${CMAKE_OBJDUMP} -i $<TARGET_FILE_NAME:input> -c ${PROJECT_BINARY_DIR}/static_input.cpp -b input_
    VERBATIM
)

add_custom_target(static_input_target
    DEPENDS ${PROJECT_BINARY_DIR}/static_input.cpp
)
