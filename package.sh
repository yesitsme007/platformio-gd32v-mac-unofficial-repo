#GCC_OUTDIR=~/opt/riscv
DFU_UTIL_SRCDIR=../gd32-dfu-utils/src
STM_FLASH_SRC_DIR=../stm32flash-code
OPENOCD_SRC_DIR=../riscv-openocd/src
#GCC_ARCHIVE=toolchain-gd32v-darwin_x86_64-9.2.0-unofficial.tar.gz
GCC_ARCHIVE=riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-apple-darwin.tar.gz
OPENOCD_ARCHIVE=tool-openocd-riscv-darwin_x86_64-0.9.20191123-unofficial.tar.gz
FLASH_ARCHIVE=tool-gd32vflash-darwin_x86_64-0.1.0-unofficial.tar.gz
GCC_DOWNLOAD_DIR=../riscv-toolchain-download-sifive
GCC_EXTRACT_DIR=riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-apple-darwin

find . -name ".DS_Store" -exec rm {} \;
# find ${GCC_OUTDIR} -name ".DS_Store" -exec rm {} \;

if [ -e ${GCC_DOWNLOAD_DIR}/${GCC_ARCHIVE} ]
then
	echo "Found toolchain not downloading"
else
    curl https://static.dev.sifive.com/dev-tools/${GCC_ARCHIVE} --output "${GCC_DOWNLOAD_DIR}/${GCC_ARCHIVE}"
fi
tar -x --cd ${GCC_DOWNLOAD_DIR} -f "${GCC_DOWNLOAD_DIR}/${GCC_ARCHIVE}"
cp toolchain-gd32v-mac/package.json ${GCC_DOWNLOAD_DIR}/${GCC_EXTRACT_DIR}
tar -czvf ${GCC_ARCHIVE} --cd ${GCC_DOWNLOAD_DIR}/${GCC_EXTRACT_DIR} .
#cleanup extracted files
rm -r ${GCC_DOWNLOAD_DIR}/${GCC_EXTRACT_DIR}

# tar -czvf ${GCC_ARCHIVE} --cd  ${GCC_OUTDIR} .

cp tool-gd32vflash-mac/package.json ${DFU_UTIL_SRCDIR}
cp ${STM_FLASH_SRC_DIR}/stm32flash ${DFU_UTIL_SRCDIR}
tar -czvf ${FLASH_ARCHIVE} --cd ${DFU_UTIL_SRCDIR} dfu-util dfu-prefix dfu-suffix stm32flash package.json

cp tool-openocd-gd32v-mac/package.json ${OPENOCD_SRC_DIR}
tar -czvf ${OPENOCD_ARCHIVE}  --cd ${OPENOCD_SRC_DIR} openocd package.json

# calc sha1 checksum and extract first token of output
SHA1TOOLCHAIN=$(shasum -a 1 ${GCC_ARCHIVE} | sed "s/ .*//g")
echo "SHA-1 of ${GCC_ARCHIVE}: ${SHA1TOOLCHAIN}"

SHA1GD32VFLASH=$(shasum -a 1 ${FLASH_ARCHIVE} | sed "s/ .*//g")
echo "SHA-1 of ${FLASH_ARCHIVE}: ${SHA1GD32VFLASH}"

SHA1OPENOCD=$(shasum -a 1 ${OPENOCD_ARCHIVE} | sed "s/ .*//g")
echo "SHA-1 of ${OPENOCD_ARCHIVE}: ${SHA1OPENOCD}"

sed -e "s/__SHA1TOOLCHAIN__/${SHA1TOOLCHAIN}/g" -e "s/__SHA1GD32VFLASH__/${SHA1GD32VFLASH}/g" -e "s/__SHA1OPENOCD__/${SHA1OPENOCD}/g" manifest_template.json > manifest.json
