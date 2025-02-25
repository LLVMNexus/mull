set(CPACK_GENERATOR DEB)
set(CPACK_DEBIAN_PACKAGE_MAINTAINER ${CPACK_PACKAGE_CONTACT})
set(CPACK_DEBIAN_PACKAGE_DESCRIPTION ${PROJECT_DESCRIPTION})

set(CPACK_DEBIAN_PACKAGE_DEPENDS
    "libz-dev, libsqlite3-dev, ncurses-dev, libstdc++-6-dev, libxml2-dev, uuid-dev"
)
