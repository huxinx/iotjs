# Copyright 2015 Samsung Electronics Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cmake_minimum_required(VERSION 2.8)

file(GLOB LIB_IOTJS_SRC ${SRC_ROOT}/*.cpp
                        ${SRC_ROOT}/platform/${PLATFORM_DESCRIPT}/*.cpp)

if("${ENABLE_LTO}" STREQUAL "ON")
    set(CFLAGS "${CFLAGS} -flto")
  # Use gcc-ar and gcc-ranlib to support LTO
   get_filename_component(PATH_TO_GCC ${CMAKE_C_COMPILER} REALPATH)
   get_filename_component(DIRECTORY_GCC ${PATH_TO_GCC} DIRECTORY)
   get_filename_component(FILE_NAME_GCC ${PATH_TO_GCC} NAME)
   string(REPLACE "gcc" "gcc-ar" CMAKE_AR ${FILE_NAME_GCC})
   string(REPLACE "gcc" "gcc-ranlib" CMAKE_RANLIB ${FILE_NAME_GCC})
   set(CMAKE_AR ${DIRECTORY_GCC}/${CMAKE_AR})
   set(CMAKE_RANLIB ${DIRECTORY_GCC}/${CMAKE_RANLIB})
endif()

set(LIB_IOTJS_CFLAGS ${CFLAGS})
set(LIB_IOTJS_INCDIR ${TARGET_INC}
                     ${INC_ROOT}
                     ${SRC_ROOT}
                     ${JERRY_INCDIR}
                     ${LIBUV_INCDIR}
                     ${HTTPPARSER_INCDIR})


add_custom_target(targetLibIoTjs)

function(BuildLibIoTjs)
  set(targetName libiotjs)

  add_library(${targetName} STATIC ${LIB_IOTJS_SRC})
  set_property(TARGET ${targetName}
               PROPERTY COMPILE_FLAGS ${LIB_IOTJS_CFLAGS})
  target_include_directories(${targetName} PRIVATE ${LIB_IOTJS_INCDIR})
endfunction()

BuildLibIoTjs()


set(SRC_MAIN ${ROOT}/iotjs_linux.cpp)

set(IOTJS_CFLAGS ${CFLAGS})
set(IOTJS_INCDIR ${INC_ROOT} ${SRC_ROOT} ${JERRY_INCDIR} ${LIBUV_INCDIR})

function(BuildIoTjs)
  set(targetName iotjs)

  add_executable(${targetName} ${SRC_MAIN})
  set_property(TARGET ${targetName}
               PROPERTY COMPILE_FLAGS "${IOTJS_CFLAGS}")
  set_property(TARGET ${targetName}
               PROPERTY LINK_FLAGS "${IOTJS_CFLAGS}")
  target_include_directories(${targetName} PRIVATE ${LIB_IOTJS_INCDIR})
  target_include_directories(${targetName} SYSTEM PRIVATE ${TARGET_INC})
  target_link_libraries(${targetName} libiotjs ${JERRY_LIB}
    ${LIBUV_LIB} ${HTTPPARSER_LIB})
  add_dependencies(targetLibIoTjs ${targetName})

endfunction()

function(BuildIoTjsLib)
  set(targetName iotjs)

  add_library(${targetName} ${SRC_MAIN})
  set_property(TARGET ${targetName}
               PROPERTY COMPILE_FLAGS "${IOTJS_CFLAGS}")
  set_property(TARGET ${targetName}
               PROPERTY LINK_FLAGS "${IOTJS_CFLAGS}")
  target_include_directories(${targetName} PRIVATE ${LIB_IOTJS_INCDIR})
  target_link_libraries(${targetName} libiotjs ${JERRY_LIB}
    ${LIBUV_LIB} ${HTTPPARSER_LIB})
  add_dependencies(targetLibIoTjs ${targetName})
endfunction()

if(${BUILD_TO_LIB})
  BuildIoTjsLib()
else()
  BuildIoTjs()
endif()
