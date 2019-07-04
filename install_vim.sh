#!/bin/bash      
#########################################################################
# File Name: config.sh
# Author: wangbin
# mail: 772384788@qq.com
# Created Time: Thu 06 Nov 2014 06:31:50 PM CST
#########################################################################
#Define Path    
VIM_PATH=$(cd `dirname $0`; pwd)
cd ${VIM_PATH}
VIMRC=$HOME/.vimrc 
VIM_FILE=./packages/vim1*

function vim_other()
{
    # 判断是否有 git 命令，如果没有 git 命令，则进行清理 vim-gitgutter 目录
    Command=git
    which $Command > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        :
    else
        echo $Command not exist
        git_dir=~/.vim/bundle/vim-gitgutter
        [[ -d ${git_dir}  ]] && rm -rf ${git_dir}
    fi
}

function scripts_generic_identifyOs()
{
    ## determine OS of computer
    os=$(uname -a)
    if [[ ${os} == *"Darwin"* ]]; then
      os="Mac"
      return 0
    elif [[ ${os} == *"Ubuntu"* ]]; then
      os="Ubuntu"
      return 0
    fi

    if [[ -e "/etc/system-release-cpe" ]]
    then
        if [[ "$(cat /etc/system-release-cpe)" == *"centos"* ]]; then
            os="Centos"
        elif [[ "$(cat /etc/system-release-cpe)" == *"redhat"* ]]; then
            os="Redhat"
        fi
    else
        os="Unrecognised"
        echo "os:${os}"
    fi
    return 0
}


function prompt() 
{
    # 输入用户名以及邮箱
    read -p "Please input your name:(default:lkcloud)" AUTHOR
    [[ -z "$AUTHOR"  ]] && AUTHOR="lkcloud"
    read -p "Please input your E-mail:(default:lkcloud@foxmail.com)" MAIL_AUTHOR
    [[ -z "$MAIL_AUTHOR"  ]] && MAIL_AUTHOR="lkcloud@foxmail.com"
}

function cleanJob() {
    [[ -d $HOME/.vim  ]] && rm -rf $HOME/.vim
}

# installCtags $install_dir
function installCtags() 
{
    check_ctags=`ls -l /usr/bin/ | grep ctags|wc -l`
    if [ "w$check_ctags" != "w0" ];then
        return 0
    fi

    mkdir -p "$1"
    tar -zxf ${VIM_PATH}/packages/ctags.tar.gz -C "$1"
    chmod 755 "$1/ctags"
}

function addBash()
{
    CK_VIM=`grep "vi='vim'" ~/.bashrc | wc -l`
    if [ "w${CK_VIM}" = "w0" ];then
        echo " " >> ~/.bashrc
        echo "alias vi='vim'" >> ~/.bashrc
    fi 
}

# installBin $install_dir
function installBin()
{
    # install go bin
    mkdir -p "$1"
    for f in $(ls ${VIM_PATH}/vim-go-ide-bin/)
    do       
        cp -f ${VIM_PATH}/vim-go-ide-bin/$f "$1/"
    done  
}

function goBin() {
    if [ ! -z $GOPATH ];then
        return $GOPATH/bin
    fi

    return $HOME/bin
}

#deine vimConfig     
function vimConfig ()      
{   
    clear
    if [ `id -u` -eq 0 ];then
        ctagBin="/usr/bin"
        installBin="$HOME/bin"
    else
        ctagBin="$HOME/bin"
        installBin="$HOME/bin"
    fi

    prompt
    cleanJob

    # untar vim install file first
    tar -zxf ${VIM_FILE} -C $HOME/

    installCtags $ctagBin
    addBash
    installBin $installBin

    # replace
    cp ${VIM_PATH}/packages/vimrc $VIMRC
    sed -i "s/lkcloud@foxmail.com/$MAIL_AUTHOR/g" $VIMRC
    sed -i "s/lkcloud/$AUTHOR/g" $VIMRC

    . ~/.bashrc
    vim_other
    echo "this vim config is success !" 
    exit 0
}      

clear 
echo " " 
echo -e "    \033[44;37m========================================================================\033[0m" 
echo -e "    \033[44;33m|------------------------------Description------------------------------\033[0m" 
echo -e "    \033[44;37m========================================================================\033[0m" 
echo -e "    \033[33m     \033[0m" 
echo -e "    \033[33m     the confing of vim is for admin\033[0m" 
echo -e "    \033[33m     \033[0m" 
echo -e "    \033[44;37m=========================================================================\033[0m" 
echo " "
echo " "

scripts_generic_identifyOs
echo "OS:"${os}

echo " "
PS3="Please input a number":              
select i in  "vimConfig" "quit"
do 
    case $i in       
        vimConfig )      
        vimConfig      
        ;;
        quit)
        exit $?
        ;;
        *)      
        echo      
        echo -e "\033[44;37mPlease Insert :vimConfig(1)|Exit(2)\033[0m" 
        echo      
        ;;      
    esac      
done 
