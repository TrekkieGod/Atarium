cmake_minimum_required(VERSION 3.18)
set(CMAKE_TOOLCHAIN_FILE Atari2600.cmake)
Project(Atarium ASM)

add_executable(sound sound.asm)
add_executable(sprite sprite.asm)

enable_testing()
add_test(NAME soundTest COMMAND stella $<TARGET_FILE:sound>.bin)
add_test(NAME spriteTest COMMAND stella $<TARGET_FILE:sprite>.bin)