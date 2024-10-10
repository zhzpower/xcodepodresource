
#!/bin/sh
echo "note: startcopy------------------------------------"
mkdir -p "${SRCROOT}/.temp" 
#清除temp.log文件
if [ -f ${SRCROOT}/.temp/temp.log ];
then
    rm -f ${SRCROOT}/.temp/temp.log
fi

# 项目中所有的 assets
arr=$1 
for i in ${arr[*]}; do
    path1_assets=$(find -L "$i" -iname "*.xcassets" -type d)
    for i in ${path1_assets[*]}
    do
        find -L "${i}" -iname "*.png" -type f -print0 | xargs -0 md5sum | awk -F'[ /]' -v OFS='|' '{print $1,$NF}'| sed 's/ //g' >> ${SRCROOT}/.temp/temp.log
    done
done

# 排序
sort ${SRCROOT}/.temp/temp.log -o ${SRCROOT}/.temp/temp.log
# 判断是否有差异, 有差异直接退出,执行原逻辑
has_changed=1
if [ -f ${SRCROOT}/.temp/old.log ];
then
    temp_md5=`md5sum "${SRCROOT}/.temp/temp.log" | awk '{print $1}' | sed 's/ //g'`
    old_md5=`md5sum "${SRCROOT}/.temp/old.log" | awk '{print $1}' | sed 's/ //g'`
    if [ $temp_md5 == $old_md5 ];
    then
        has_changed=0
    else
        echo "warning: old.log vx temp.log 有差异, 执行原逻辑"
    fi
else
    echo "note: .temp/old.log 不存在, 执行原逻辑"
fi

# copy缓存的car到app
if [ $has_changed == 0 ];
then
    Assets_Car_Cache_Path="${SRCROOT}/.temp/Assets.car" 
    if [ -f $Assets_Car_Cache_Path ]; 
    then 
        echo "note: startcopy ${Assets_Car_Cache_Path}------------"
        App_File_Path=${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH} 
        echo "note: 执行前App文件大小: ""`du -sm ${App_File_Path}`"
        cp ${Assets_Car_Cache_Path} ${App_File_Path} 
        if [ $? == 0 ]; 
        then 
            echo "note: Copy file size: ""`du -sm ${App_File_Path}`"
            echo "note: copy finish..."
        fi 
    else
        has_changed=1
        echo "warning: .temp/Assets.car 不存在, 执行原逻辑"
    fi
fi
