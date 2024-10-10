#!/bin/sh

# 1. 非debug环境不生效
if [[ "$CONFIGURATION" != "Debug" ]]; then
    echo "warning: 当前编译环境为: ""$CONFIGURATION"", 缓存不生效"
    exit 0
fi

# 2. 插入Cache Assets.car逻辑
sh_path="${PODS_ROOT}/Target Support Files/Pods-${PRODUCT_NAME}/Pods-${PRODUCT_NAME}-resources.sh"
if [ `grep -c Assets.car---- "$sh_path"` == '0' ];
then
    echo "note: insert cache info..."
    sed -in-place '$a \
    \
    echo "note: cache Assets.car---------------------------------------------------------------" \
    cp "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Assets.car" "${SRCROOT}/.temp/Assets.car" \
    if [ $has_changed == 1 ] && [ -f ${SRCROOT}/.temp/temp.log ]; \
    then \
        cp ${SRCROOT}/.temp/temp.log ${SRCROOT}/.temp/old.log \
        echo "note: cache image md5 log finish......" \
    fi \
    if [ -f "${SRCROOT}/.temp/Assets.car" ]; \
    then \
        echo "note: cache finish......" \
    fi' "$sh_path"
fi
echo "note: cache finish！！！位置：.temp/Assets.car"

# 3. 根据配置决定是否生效Copy缓存Assets.car逻辑, 1生效
mkdir -p "${SRCROOT}/.temp"
if [ ! -f "${SRCROOT}/.temp/config" ];
then
    echo "1" > "${SRCROOT}/.temp/config"
fi

if [ `cat "${SRCROOT}/.temp/config"` != '1' ];
then
    echo "warning: config不为1, 不执行cache!!!"
    Assets_Car_Cache_Path="${SRCROOT}/.temp/Assets.car"
    if [ -f $Assets_Car_Cache_Path ];
    then
        rm -rf $Assets_Car_Cache_Path
        echo "warning: rm Assets.car"
    fi
    exit 0
fi

# 4. 插入copy assets.car逻辑
if [ `grep -c copy_assets_car.sh "$sh_path"` == '0' ];
then
    echo "insert copy info..."
    sed -in-place -e 's#done <<<"$OTHER_XCASSETS"#done <<<"$OTHER_XCASSETS"\
    \
    chmod +x ${SRCROOT}/Shell/copy_assets_car.sh \
    source ${SRCROOT}/Shell/copy_assets_car.sh "${XCASSET_FILES[*]}" \
    if [ $has_changed == 0 ]; \
    then \
        exit 0 \
    fi \
    #g' "$sh_path"
fi
echo "note: insert finish！！！"
