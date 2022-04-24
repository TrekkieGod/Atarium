cmake_minimum_required(VERSION 3.18)
set(ENV{CMAKE_TOOLCHAIN_FILE} Atari2600.cmake)
Project(Atarium ASM)

add_executable(game sound.s)

enable_testing()
add_test(NAME gameTest COMMAND stella $<TARGET_FILE:game>.bin)