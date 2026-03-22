add_executable(mupen64plus)

find_package(Threads REQUIRED)
find_package(SDL2 REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(PNG REQUIRED libpng)

set(UI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/mupen64plus-ui-console)

target_link_libraries(mupen64plus
PRIVATE
    rsp
    video
    core
    SDL2::SDL2
    Threads::Threads
    ${PNG_LIBRARIES}
    z
)

target_include_directories(mupen64plus
PRIVATE
    ${UI_DIR}/src
    ${CORE_DIR}/src/api
)

add_dependencies(mupen64plus static_core_target)
add_dependencies(mupen64plus static_video_target)
add_dependencies(mupen64plus static_rsp_target)

target_sources(mupen64plus
PRIVATE
    ${UI_DIR}/src/cheat.c
    ${UI_DIR}/src/compare_core.c
    ${UI_DIR}/src/core_interface.c
    ${UI_DIR}/src/debugger.c
    ${UI_DIR}/src/main.c
    ${UI_DIR}/src/plugin.c
    ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/static_link.cpp
    ${PROJECT_BINARY_DIR}/static_core.cpp
    ${PROJECT_BINARY_DIR}/static_video.cpp
    ${PROJECT_BINARY_DIR}/static_rsp.cpp
)
