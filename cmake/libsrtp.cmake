add_library(libsrtp OBJECT EXCLUDE_FROM_ALL)
init_target(libsrtp)
add_library(tg_owt::libsrtp ALIAS libsrtp)

if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    message(STATUS "iOS target_include_directories ${CMAKE_SOURCE_DIR}")

    # 设置头文件路径
    target_include_directories(libsrtp PRIVATE
        ${third_party_loc}/openssl/arm64/include
    )

    # 设置库文件路径
    target_link_directories(libsrtp PRIVATE
        ${third_party_loc}/openssl/arm64/lib
    )
    target_link_libraries(libsrtp PRIVATE
        ssl
        crypto
    )
else()
    link_libsrtp(libsrtp)
endif()

set(libsrtp_loc ${third_party_loc}/libsrtp)

nice_target_sources(libsrtp ${libsrtp_loc}
    PRIVATE

    # includes
    include/ekt.h
    include/getopt_s.h
    include/srtp.h
    include/srtp_priv.h
    include/ut_sim.h

    # headers
    crypto/include/aes.h
    crypto/include/aes_icm.h
    crypto/include/alloc.h
    crypto/include/auth.h
    crypto/include/cipher.h
    crypto/include/crypto_kernel.h
    crypto/include/crypto_types.h
    crypto/include/datatypes.h
    crypto/include/err.h
    crypto/include/integers.h
    crypto/include/key.h
    crypto/include/null_auth.h
    crypto/include/null_cipher.h
    crypto/include/rdb.h
    crypto/include/rdbx.h
    crypto/include/stat.h
    crypto/cipher/aes_gcm_ossl.c
    crypto/cipher/aes_icm_ossl.c
    crypto/cipher/cipher.c
    crypto/cipher/null_cipher.c
    crypto/hash/auth.c
    crypto/hash/hmac_ossl.c
    crypto/hash/null_auth.c
    crypto/kernel/alloc.c
    crypto/kernel/crypto_kernel.c
    crypto/kernel/err.c
    crypto/kernel/key.c
    crypto/math/datatypes.c
    crypto/math/stat.c
    crypto/replay/rdb.c
    crypto/replay/rdbx.c
    crypto/replay/ut_sim.c
    srtp/ekt.c
    srtp/srtp.c
)

target_compile_definitions(libsrtp PRIVATE HAVE_CONFIG_H)

if(CMAKE_SYSTEM_NAME STREQUAL "iOS")
    target_include_directories(libsrtp
        PRIVATE
        ${third_party_loc}/openssl/arm64/include
        ${third_party_loc}/libsrtp/include
        ${third_party_loc}/libsrtp/crypto/include
    )
else()
endif()

target_include_directories(libsrtp
    PUBLIC
    $<BUILD_INTERFACE:${libsrtp_loc}/include>
    $<BUILD_INTERFACE:${libsrtp_loc}/crypto/include>
    $<BUILD_INTERFACE:${libsrtp_loc}/../libsrtp_config>
    $<INSTALL_INTERFACE:${webrtc_includedir}/third_party/libsrtp/include>
    $<INSTALL_INTERFACE:${webrtc_includedir}/third_party/libsrtp/crypto/include>
)
