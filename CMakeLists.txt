cmake_minimum_required(VERSION 3.31)
project(dmenu C)
set(CMAKE_C_STANDARD 99)
set(DMENU_VERSION 5.3)
set(PERMISSIONS_644 OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ)
set(PERMISSIONS_755
    OWNER_READ
    OWNER_EXECUTE
    OWNER_WRITE
    GROUP_EXECUTE
    GROUP_READ
    WORLD_EXECUTE
    WORLD_READ)
add_compile_definitions(VERSION="${DMENU_VERSION}")

add_executable(
  dmenu
  arg.h
  CMakeLists.txt
  config.h
  dmenu.c
  drw.c
  drw.h
  util.c
  util.h)

add_executable(stest stest.c arg.h)

install(
  TARGETS dmenu
  PERMISSIONS ${PERMISSIONS_755}
  RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)

install(
  TARGETS stest
  PERMISSIONS ${PERMISSIONS_755}
  RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)

install(
  FILES dmenu_run dmenu_path
  PERMISSIONS ${PERMISSIONS_755}
  DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)

install(
  FILES dmenu.1 stest.1
  DESTINATION ${CMAKE_INSTALL_PREFIX}/share/man/man1/
  PERMISSIONS ${PERMISSIONS_644})

install(
  CODE "execute_process(COMMAND sed -i \"s/VERSION/${DMENU_VERSION}/g\" ${CMAKE_INSTALL_PREFIX}/share/man/man1/dmenu.1)"
)

install(
  CODE "execute_process(COMMAND sed -i \"s/VERSION/${DMENU_VERSION}/g\" ${CMAKE_INSTALL_PREFIX}/share/man/man1/stest.1)"
)

find_package(X11 REQUIRED)
find_package(Freetype REQUIRED)
find_package(Fontconfig REQUIRED)

target_link_libraries(
  dmenu
  PRIVATE ${Fontconfig_LIBRARY}
          ${X11_LIBRARIES}
          ${X11_x11_LIB}
          ${X11_Xinerama_LIB}
          ${X11_Xrender_LIB}
          ${X11_Xft_LIB}
          ${FREETYPE_LIBRARY_RELEASE}
          m)

target_include_directories(
  dmenu
  PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
         ${Fontconfig_INCLUDE_DIR}
         ${X11_INCLUDE_DIR}
         ${X11_X11_INCLUDE_PATH}
         ${X11_Xrender_INCLUDE_PATH}
         ${X11_Xft_INCLUDE_PATH}
         ${X11_Xinerama_INCLUDE_PATH}
         ${FREETYPE_INCLUDE_DIR_freetype2})
