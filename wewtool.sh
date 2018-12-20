#!/usr/bin/env bash

APP_NAME="企业微信"
FRAMEWORK_NAME=WeChatWorkPlugin
APP_BUNDLE_PATH="/Applications/${APP_NAME}.app/Contents/MacOS"
APP_EXECUTABLE_PATH="${APP_BUNDLE_PATH}/${APP_NAME}"
APP_EXECUTABLE_BACKUP_PATH="${APP_EXECUTABLE_PATH}_backup"
FRAMEWORK_PATH="${APP_BUNDLE_PATH}/${FRAMEWORK_NAME}.framework"
BUILD_OUTPUT_PATH=./Other/Products/Debug

Usage() {
    printf "Usage: $0 [ ${CMSG}install${CEND} | ${CMSG}uninstall${CEND} ]"
}

install() {
    if test ! -f ${APP_EXECUTABLE_PATH}; then
        echo "请检查是否安装 ${APP_NAME} "
        exit 1
    fi

    if test ! -w ${APP_BUNDLE_PATH}; then
        echo -e "\n\n为了将小助手写入, 请输入密码 ： "
        sudo chown -R $(whoami) "${APP_BUNDLE_PATH}"
    fi

    if test -f ${APP_EXECUTABLE_BACKUP_PATH}; then
        read -t 150 -p "已安装小助手，是否覆盖？[y/n]:" confirm
        if [[ "${confirm}" == 'y' ]]; then
            rm -rf ${FRAMEWORK_PATH}
            cp -R "${BUILD_OUTPUT_PATH}/${FRAMEWORK_NAME}.framework" ${FRAMEWORK_PATH}
            echo "更新成功, 重启 ${APP_NAME} 生效"
        else
            echo "取消安装"
        fi
    else
        rm -rf ${FRAMEWORK_PATH}
        cp -R "${BUILD_OUTPUT_PATH}/${FRAMEWORK_NAME}.framework" ${FRAMEWORK_PATH}
        cp ${APP_EXECUTABLE_PATH} ${APP_EXECUTABLE_BACKUP_PATH}
        ./Other/insert_dylib ${FRAMEWORK_PATH}/${FRAMEWORK_NAME} ${APP_EXECUTABLE_BACKUP_PATH} ${APP_EXECUTABLE_PATH} --all-yes
        echo "安装成功, 重启 ${APP_NAME} 生效"
    fi
}

uninstall(){
    if [[ ! -f ${APP_EXECUTABLE_PATH} ]]; then
        echo "请检查是否安装 ${APP_NAME} "
        exit 1
    fi

    if test -f ${APP_EXECUTABLE_BACKUP_PATH}; then
        rm -rf ${FRAMEWORK_PATH} ${APP_EXECUTABLE_PATH}
        mv ${APP_EXECUTABLE_BACKUP_PATH} ${APP_EXECUTABLE_PATH}
        echo "卸载成功, 请重启 ${APP_NAME}"
    else
        echo "卸载失败, 可能未安装"
    fi
}

case $1 in
    install)
        install
    ;;
    uninstall)
        uninstall
    ;;
    *)
     Usage
esac