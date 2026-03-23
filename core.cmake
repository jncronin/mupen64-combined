find_package(SDL2)

set(CORE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/mupen64plus-core")

add_library(asm_defines)

target_include_directories(asm_defines
PRIVATE
    ${CORE_DIR}/src
    ${CORE_DIR}/src/asm_defines
)

target_sources(asm_defines
PRIVATE
    ${CORE_DIR}/src/asm_defines/asm_defines.c
)

add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/asm_defines_nasm.h ${PROJECT_BINARY_DIR}/asm_defines_gas.h
    DEPENDS asm_defines
    COMMAND ${CMAKE_COMMAND} -E rm -f ${PROJECT_BINARY_DIR}/asm_defines_nasm.h
    COMMAND ${CMAKE_COMMAND} -E rm -f ${PROJECT_BINARY_DIR}/asm_defines_gas.h
    COMMAND bash ${CORE_DIR}/tools/gen_asm_script.sh ${PROJECT_BINARY_DIR} $<TARGET_FILE_NAME:asm_defines>
    VERBATIM
)

add_custom_target(asm_defines_target
    DEPENDS ${PROJECT_BINARY_DIR}/asm_defines_nasm.h ${PROJECT_BINARY_DIR}/asm_defines_gas.h
)

add_library(core)

add_dependencies(core asm_defines_target)

target_include_directories(core
PRIVATE
    ${CORE_DIR}/src
    ${CORE_DIR}/src/asm_defines
    ${CORE_DIR}/subprojects/xxhash
    ${CORE_DIR}/subprojects/minizip
    ${CORE_DIR}/subprojects/md5
    ${CORE_DIR}/subprojects
    ${PROJECT_BINARY_DIR}/
)

target_compile_definitions(core
PRIVATE
    M64P_PARALLEL
    NO_CRYPT
    NO_UNCRYPT
    IOAPI_NO_64
)

target_link_libraries(core
PUBLIC
    asm_defines
    SDL2::SDL2
    z
)

target_sources(core
PRIVATE
    ${CORE_DIR}/src/api/callbacks.c
    ${CORE_DIR}/src/api/common.c
    ${CORE_DIR}/src/api/config.c
    ${CORE_DIR}/src/api/debugger.c
    ${CORE_DIR}/src/api/frontend.c
    ${CORE_DIR}/src/api/vidext.c
    ${CORE_DIR}/src/backends/api/video_capture_backend.c
    ${CORE_DIR}/src/backends/plugins_compat/audio_plugin_compat.c
    ${CORE_DIR}/src/backends/plugins_compat/input_plugin_compat.c
    ${CORE_DIR}/src/backends/clock_ctime_plus_delta.c
    ${CORE_DIR}/src/backends/dummy_video_capture.c
    ${CORE_DIR}/src/backends/file_storage.c
    ${CORE_DIR}/src/device/cart/cart.c
    ${CORE_DIR}/src/device/cart/af_rtc.c
    ${CORE_DIR}/src/device/cart/cart_rom.c
    ${CORE_DIR}/src/device/cart/eeprom.c
    ${CORE_DIR}/src/device/cart/flashram.c
    ${CORE_DIR}/src/device/cart/is_viewer.c
    ${CORE_DIR}/src/device/cart/sram.c
    ${CORE_DIR}/src/device/controllers/game_controller.c
    ${CORE_DIR}/src/device/controllers/vru_controller.c
    ${CORE_DIR}/src/device/controllers/paks/biopak.c
    ${CORE_DIR}/src/device/controllers/paks/mempak.c
    ${CORE_DIR}/src/device/controllers/paks/rumblepak.c
    ${CORE_DIR}/src/device/controllers/paks/transferpak.c
    ${CORE_DIR}/src/device/dd/dd_controller.c
    ${CORE_DIR}/src/device/dd/disk.c
    ${CORE_DIR}/src/device/device.c
    ${CORE_DIR}/src/device/gb/gb_cart.c
    ${CORE_DIR}/src/device/gb/mbc3_rtc.c
    ${CORE_DIR}/src/device/gb/m64282fp.c
    ${CORE_DIR}/src/device/memory/memory.c
    ${CORE_DIR}/src/device/pif/bootrom_hle.c
    ${CORE_DIR}/src/device/pif/cic.c
    ${CORE_DIR}/src/device/pif/n64_cic_nus_6105.c
    ${CORE_DIR}/src/device/pif/pif.c
    ${CORE_DIR}/src/device/r4300/cached_interp.c
    ${CORE_DIR}/src/device/r4300/cp0.c
    ${CORE_DIR}/src/device/r4300/cp1.c
    ${CORE_DIR}/src/device/r4300/cp2.c
    ${CORE_DIR}/src/device/r4300/idec.c
    ${CORE_DIR}/src/device/r4300/interrupt.c
    ${CORE_DIR}/src/device/r4300/pure_interp.c
    ${CORE_DIR}/src/device/r4300/r4300_core.c
    ${CORE_DIR}/src/device/r4300/tlb.c
    ${CORE_DIR}/src/device/rcp/ai/ai_controller.c
    ${CORE_DIR}/src/device/rcp/mi/mi_controller.c
    ${CORE_DIR}/src/device/rcp/pi/pi_controller.c
    ${CORE_DIR}/src/device/rcp/rdp/fb.c
    ${CORE_DIR}/src/device/rcp/rdp/rdp_core.c
    ${CORE_DIR}/src/device/rcp/ri/ri_controller.c
    ${CORE_DIR}/src/device/rcp/rsp/rsp_core.c
    ${CORE_DIR}/src/device/rcp/si/si_controller.c
    ${CORE_DIR}/src/device/rcp/vi/vi_controller.c
    ${CORE_DIR}/src/device/rdram/rdram.c
    ${CORE_DIR}/src/main/main.c
    ${CORE_DIR}/src/main/util.c
    ${CORE_DIR}/src/main/cheat.c
    ${CORE_DIR}/src/main/eventloop.c
    ${CORE_DIR}/src/main/rom.c
    ${CORE_DIR}/src/main/savestates.c
    ${CORE_DIR}/src/main/screenshot.c
    ${CORE_DIR}/src/main/sdl_key_converter.c
    ${CORE_DIR}/src/main/workqueue.c
    ${CORE_DIR}/src/plugin/plugin.c
    ${CORE_DIR}/src/plugin/dummy_video.c
    ${CORE_DIR}/src/plugin/dummy_audio.c
    ${CORE_DIR}/src/plugin/dummy_input.c
    ${CORE_DIR}/src/plugin/dummy_rsp.c
    ${CORE_DIR}/src/device/r4300/new_dynarec/new_dynarec.c

    ${CORE_DIR}/src/osal/files_unix.c

    ${CORE_DIR}/subprojects/md5/md5.c

    ${CORE_DIR}/subprojects/minizip/ioapi.c
    ${CORE_DIR}/subprojects/minizip/zip.c
    ${CORE_DIR}/subprojects/minizip/unzip.c
)

if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86")
    set(DYNAREC 1)
    enable_language(ASM_NASM)
    target_compile_definitions(core
    PRIVATE
        NEW_DYNAREC=1
        DYNAREC
    )
    target_compile_definitions(asm_defines
    PRIVATE
        NEW_DYNAREC=1
        DYNAREC
    )
    target_sources(core
    PRIVATE
        ${CORE_DIR}/src/device/r4300/new_dynarec/x86/linkage_x86.asm
    )
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    set(DYNAREC 1)
    enable_language(ASM_NASM)
    target_compile_definitions(core
    PRIVATE
        NEW_DYNAREC=2
        DYNAREC
    )
    target_compile_definitions(asm_defines
    PRIVATE
        NEW_DYNAREC=2
        DYNAREC
    )
    target_sources(core
    PRIVATE
        ${CORE_DIR}/src/device/r4300/new_dynarec/x64/linkage_x64.asm
    )
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "arm")
    set(DYNAREC 1)
    target_compile_definitions(core
    PRIVATE
        NEW_DYNAREC=3
        DYNAREC
    )
    target_compile_definitions(asm_defines
    PRIVATE
        NEW_DYNAREC=3
        DYNAREC
    )
    target_sources(core
    PRIVATE
        ${CORE_DIR}/src/device/r4300/new_dynarec/arm/linkage_arm.S
        ${CORE_DIR}/src/device/r4300/new_dynarec/arm/arm_cpu_features.c
    )
elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "aarch64")
    set(DYNAREC 1)
    target_compile_definitions(core
    PRIVATE
        NEW_DYNAREC=4
        DYNAREC
    )
    target_compile_definitions(asm_defines
    PRIVATE
        NEW_DYNAREC=4
        DYNAREC
    )
    target_sources(core
    PRIVATE
        ${CORE_DIR}/src/device/r4300/new_dynarec/arm64/linkage_arm64.S
    )
endif()

add_custom_command(
    TARGET core POST_BUILD
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/redefine_syms.py -o ${CMAKE_OBJDUMP} -i $<TARGET_FILE_NAME:core> -r ${PROJECT_BINARY_DIR}/core_syms.txt -b core_
    COMMAND ${CMAKE_OBJCOPY} --redefine-syms=${PROJECT_BINARY_DIR}/core_syms.txt $<TARGET_FILE_NAME:core>
)

add_custom_command(
    OUTPUT ${PROJECT_BINARY_DIR}/static_core.cpp
    DEPENDS core ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/gen_static_link.py
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/static_link_stub/gen_static_link.py -o ${CMAKE_OBJDUMP} -i $<TARGET_FILE_NAME:core> -c ${PROJECT_BINARY_DIR}/static_core.cpp -b core_
    VERBATIM
)

add_custom_target(static_core_target
    DEPENDS ${PROJECT_BINARY_DIR}/static_core.cpp
)
