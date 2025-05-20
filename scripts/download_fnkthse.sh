source ./download.sh
source ../.env

mkdir ../services/fnkth.se 2> /dev/null

install_release fysiksektionens-naringslivsnamnd/hemsida build.tar.gz ../services/fnkth.se $FNKTHSE_VERSION
