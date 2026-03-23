cmake_minimum_required(VERSION 3.17 FATAL_ERROR)

project(mupen64p C CXX ASM)

include(${CMAKE_CURRENT_SOURCE_DIR}/core.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/rsp.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/video.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/audio.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/ui.cmake)

install(TARGETS mupen64plus)
include(CPack)
