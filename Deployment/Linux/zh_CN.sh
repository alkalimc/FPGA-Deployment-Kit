#!/bin/bash
# Powered by QiGao
# Copyright 2025- alkali. All Rights Reserved.
################################################################

FDK_VERSION="0.1"
FDK_VERSION_TYPE="Developer_Beta"
PYTHON_VERSION="3.12.7"
PYPI_MIRROR="https://mirrors.sustech.edu.cn/pypi/web/simple"
HF_ENDPOINT="https://hf-mirror.com"

################################################################

echo
echo "FPGA-Deployment-Kit 部署工具"
echo "Powered by QiGao"
echo "Copyright 2025- alkali. All Rights Reserved."
echo
echo "################################################################"

echo
echo "FDK 版本: $FDK_VERSION, 类型: $FDK_VERSION_TYPE"

while true; do
    read -p "是否继续部署进程 (y/N): " choice
    case "${choice,,}" in
        y)
            break
            ;;
        n)
            echo "放弃部署"
            exit 0
            ;;
        *)
            echo "无效输入"
            ;;
    esac
done

################################################################

echo "正在初始化部署环境"

FDK_DIR="$(realpath "$(dirname "$(realpath "$0")")/../..")"
PARENT_DIR="$(realpath "$FDK_DIR/..")"

ENVIRONMENT_FILE="$FDK_DIR/.env"

################################################################

echo
if [ -d "$PARENT_DIR/Repositories" ]; then
    echo "使用现有存储库"
else
    echo "正在创建存储库"
    mkdir -p "$PARENT_DIR/Repositories"
fi

REPOSITORIES_DIR=$PARENT_DIR/Repositories

if [ -d "$REPOSITORIES_DIR/Backups" ]; then
    echo "使用现有备份库"
else
    echo "正在创建备份库"
    mkdir -p "$REPOSITORIES_DIR/Backups"
fi

BACKUPS_DIR="$REPOSITORIES_DIR/Backups"

if [ -d "$REPOSITORIES_DIR/Logs" ]; then
    echo "使用现有日志库"
else
    echo "正在创建日志库"
    mkdir -p "$REPOSITORIES_DIR/Logs"
fi

LOGS_DIR="$REPOSITORIES_DIR/Logs"

################################################################

DATE="$(date +%F)"
TIME="$(date +%H-%M-%S)"

mkdir -p "$LOGS_DIR/Deployment/$DATE"
echo "TIME=$(date +%s%N)" > "$LOGS_DIR/Deployment/$DATE/$TIME.log"

DEPLOYMENT_LOG_FILE="$LOGS_DIR/Deployment/$DATE/$TIME.log"

echo "FDK_VERSION=$FDK_VERSION" >> "$DEPLOYMENT_LOG_FILE"
echo "FDK_VERSION_TYPE=$FDK_VERSION_TYPE" >> "$DEPLOYMENT_LOG_FILE"
echo "PYTHON_VERSION=$PYTHON_VERSION" >> "$DEPLOYMENT_LOG_FILE"
echo "PYPI_MIRROR=$PYPI_MIRROR" >> "$DEPLOYMENT_LOG_FILE"
echo "HF_ENDPOINT=$HF_ENDPOINT" >> "$DEPLOYMENT_LOG_FILE"

log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$DEPLOYMENT_LOG_FILE"
}

echo
echo "正在初始化环境变量"
log
log "################################################################"
log
log "初始化环境变量" 

if [ ! [ -d "/usr/bin/git" ] ]; then
    echo "缺失必要依赖环境 GIT, 请手动安装, 参见: https://git-scm.com/downloads/linux"
    log "缺失必要依赖环境 GIT" 

    exit 1
fi

echo "检测到必要依赖环境 GIT: "
echo
git --version
echo
echo "################################################################"

log "检测到必要依赖环境 GIT: "
log 
log "$(echo "$(git --version)")"
log
log "################################################################"

if [ -d "/usr/local/cuda" ]; then
    if [ -z "$CUDA_PATH" ]; then
        export CUDA_PATH="/usr/local/cuda"
    else
        export CUDA_PATH="$CUDA_PATH:/usr/local/cuda"
    fi
else
    echo "缺失必要依赖环境 CUDA, 请手动安装, 参见: https://developer.nvidia.com/cuda-downloads"
    log "缺失必要依赖环境 CUDA" 

    exit 1
fi
if [ -d "/usr/local/cuda/bin" ]; then
    export PATH="$PATH:/usr/local/cuda/bin"
else
    echo "必要依赖环境 CUDA 不完整, /usr/local/cuda/bin 不可达, 请手动修复, 参见: https://developer.nvidia.com/cuda-downloads"
    log "必要依赖环境 CUDA 不完整, /usr/local/cuda/bin 不可达" 

    exit 1
fi
if [ -d "/usr/local/cuda/lib64" ]; then
    if [ -z "$LD_LIBRARY_PATH" ]; then
        export LD_LIBRARY_PATH="/usr/local/cuda/lib64"
    else
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"
    fi
else
    echo "必要依赖环境 CUDA 不完整, /usr/local/cuda/lib64 不可达, 请手动修复, 参见: https://developer.nvidia.com/cuda-downloads"
    log "必要依赖环境 CUDA 不完整, /usr/local/cuda/lib64 不可达" 

    exit 1
fi

echo "检测到必要依赖环境 CUDA: "
echo
nvcc -V
echo
echo "################################################################"

log "检测到必要依赖环境 CUDA: "
log 
log "$(echo "$(nvcc -V)")"
log
log "################################################################"

################################################################

echo
echo "正在初始化虚拟化服务"
log
log "正在初始化虚拟化服务" 

if [ -d "$HOME/anaconda3" ]; then
    echo "检测到必要依赖环境 Anaconda: "
    echo
    conda -V
    echo
    echo "################################################################"

    log "检测到必要依赖环境 Anaconda" 
    log
    log "$(echo "$(conda -V)")" 
    log
    log "################################################################"
else
    echo "缺失必要依赖环境 Anaconda3, 请先手动安装, 参见: https://www.anaconda.com/download"
    log "缺失必要依赖环境 Anaconda3" 

    exit 1
fi

CONDA_DIR="$HOME/anaconda3"

################################################################

echo
echo "正在检测网络连通性"
log
log "正在检测网络连通性"

if ping -c 1 github.com &> "/dev/null"; then
    echo "网络连通性正常"
    log "网络连通性正常" 
else
    echo "网络连通性不良"
    log "网络连通性不良" 

    while true; do
        read -p "是否使用代理 (y/N): " choice
        log "是否使用代理 (y/N): $choice" 
        case "${choice,,}" in
            y)
                break
                ;;
            n)
                echo "放弃部署, 所有可逆操作已撤销"
                log "放弃部署, 所有可逆操作已撤销" 

                exit 0
                ;;
            *)
                echo "无效输入"
                log "无效输入" 
                ;;
        esac
    done

    while true; do
        read -p "键入http代理地址: " input
        log "键入http代理地址: $input" 
        if [ -z "$input" ]; then
            echo "无效输入"
            log "无效输入" 
        else
            export http_proxy="$input"

            break
        fi
    done

    while true; do
        read -p "键入https代理地址: " input
        log "键入https代理地址: $input" 
        if [ -z "$input" ]; then
            echo "无效输入"
            log "无效输入" 
        else
            export https_proxy="$input"
            
            break
        fi
    done

    echo
    echo "################################################################"
    log
    log "################################################################"
fi

################################################################

echo
echo "正在处理镜像源"
log
log "正在处理镜像源" 

while true; do
    read -p "是否使用 Hugging Face 镜像站 (y/N): " choice
    log "是否使用 Hugging Face 镜像站 (y/N): $choice"
    case "${choice,,}" in
        y)
            break
            ;;
        n)
            unset HF_ENDPOINT
            break
            ;;
        *)
            echo "无效输入"
            log "无效输入" 
            ;;
    esac
done

HUGGING_FACE_TOKEN=""

while true; do
    read -p "键入 Hugging Face Token: " input
    log "键入 Hugging Face Token: $input"
    if [ -z "$input" ]; then
        echo "无效输入"
        log "无效输入" 
    else
        HUGGING_FACE_TOKEN="$input"
        break
    fi
done

echo
echo "################################################################"
log
log "################################################################"

################################################################

echo
echo "正在初始化虚拟化环境"
log
log "正在初始化虚拟化环境"

ENVIRONMENT_DIR="$CONDA_DIR/envs/FDK"

if [ -d "$ENVIRONMENT_DIR" ]; then
    echo
    echo "检测到同名虚拟环境 FDK"
    log
    log "检测到同名虚拟环境 FDK" 

    while true; do
        read -p "是否覆盖 (y/N): " choice
        log "是否覆盖 (y/N): $choice" 
        case "${choice,,}" in
            y)
                read -p "是否覆盖同名环境!!! (y/N): " choice
                log "是否覆盖同名环境!!! (y/N): $choice"
                case "${choice,,}" in
                    y)
                        echo "正在删除同名环境"
                        log "正在删除同名环境"
                        conda remove -n FDK --all -y
                        break
                        ;;
                    n)
                        echo "保留同名环境"
                        log "保留同名环境" 

                        while true; do
                            read -p "键入其他的环境名称, 如果键入 FDK 视作在该同名环境中部署: " input
                            log "键入其他的环境名称, 如果键入 FDK 视作在该同名环境中部署: $input" 

                            if [ -z "$input" ]; then
                                echo "无效输入"
                                log "无效输入" 
                            elif [ "$input" == "FDK" ]; then
                                echo "正在同名环境中部署"
                                log "正在同名环境中部署" 
        
                                break
                            else
                                echo "正在部署虚拟化环境"
                                log "正在部署虚拟化环境" 
        
                                conda create -n $input python="$PYTHON_VERSION" -y
                                ENVIRONMENT_DIR="$CONDA_DIR/envs/$input"
        
                                break
                            fi
                        done

                        break
                        ;;
                    *)
                        echo "无效输入"
                        log "无效输入" 
                        ;;
                esac
                
                break
                ;;
            n)
                echo "保留同名环境"
                log "保留同名环境" 

                while true; do
                    read -p "键入其他的环境名称, 如果键入 FDK 视作在该同名环境中部署: " input
                    log "键入其他的环境名称, 如果键入 FDK 视作在该同名环境中部署: $input" 

                    if [ -z "$input" ]; then
                        echo "无效输入"
                        log "无效输入" 
                    elif [ "$input" == "FDK" ]; then
                        echo "正在同名环境中部署"
                        log "正在同名环境中部署" 

                        break
                    else
                        echo "正在部署虚拟化环境"
                        log "正在部署虚拟化环境" 

                        conda create -n $input python="$PYTHON_VERSION" -y
                        ENVIRONMENT_DIR="$CONDA_DIR/envs/$input"

                        break
                    fi
                done

                break
                ;;
            *)
                echo "无效输入"
                log "无效输入" 
                ;;
        esac
    done
else
    echo "正在部署虚拟化环境"
    echo
    log "正在部署虚拟化环境"
    log

    conda create -n FDK python="$PYTHON_VERSION" -y
fi

export PATH="$ENVIRONMENT_DIR/bin:$PATH"

echo
echo "################################################################"
log
log "################################################################"

################################################################

echo
echo "正在初始化运行环境"
log
log "正在初始化运行环境" 

ENVIRONMENT_BACKUP_FILE="None"

if [ -f "$ENVIRONMENT_FILE" ]; then
    echo "检测到环境中已有的环境变量文件"
    log "检测到环境中已有的环境变量文件" 

    while true; do
        read -p "是否覆盖 (y/N): " choice
        log "是否覆盖 (y/N): $choice" 
        case "${choice,,}" in
            y)
                mkdir -p "$BACKUPS_DIR/Environment/$DATE"
                mv "$ENVIRONMENT_FILE" "$BACKUPS_DIR/Environment/$DATE/.env.$TIME.bk"
                ENVIRONMENT_BACKUP_FILE="$BACKUPS_DIR/Environment/$DATE/.env.$TIME.bk"

                break
                ;;
            n)
                echo "放弃部署, 所有可逆操作已撤销"
                log "放弃部署, 所有可逆操作已撤销" 
                
                exit 0
                ;;
            *)
                echo "无效输入"
                log "无效输入" 
                ;;
        esac
    done
else
    echo "开始全新部署"
    log "开始全新部署" 
fi

################################################################

echo
echo "正在初始化环境变量"
log
log "正在初始化环境变量" 

echo "#!/bin/bash" > "$ENVIRONMENT_FILE"

environment() {
    case "$2" in
        1)
            if [ -n "${!1}" ]; then
                echo "export $1=${!1}" >> "$ENVIRONMENT_FILE"
            else
                echo "#$1=None" >> "$ENVIRONMENT_FILE"
            fi
            ;;
        0)
            if [ -n "${!1}" ]; then
                echo "$1=${!1}" >> "$ENVIRONMENT_FILE"
            else
                echo "#$1=None" >> "$ENVIRONMENT_FILE"
            fi
            ;;
        -1)
            if [ -n "${!1}" ]; then
                echo "#$1=${!1}" >> "$ENVIRONMENT_FILE"
            else
                echo "#$1=None" >> "$ENVIRONMENT_FILE"
            fi
            ;;
        *)
            echo "$2" >> "$ENVIRONMENT_FILE"
            ;;
    esac
}

environment "" ""
environment "FDK_VERSION" "0"
environment "FDK_VERSION_TYPE" "0"
environment "PYTHON_VERSION" "0"
environment "PYPI_MIRROR" "0"
environment "HF_ENDPOINT" "1"
environment "" ""
environment "" "################################################################"
environment "" ""
environment "DATE" "-1"
environment "TIME" "-1"
environment "DEPLOYMENT_LOG_FILE" "-1"
environment "" ""
environment "" "################################################################"
environment "" ""
environment "FDK_DIR" "1"
environment "ENVIRONMENT_FILE" "1"
environment "" ""
environment "ENVIRONMENT_DIR" "0"
environment "" ""
environment "REPOSITORIES_DIR" "0"
environment "BACKUPS_DIR" "0"
environment "LOGS_DIR" "0"
environment "" ""
environment "" "################################################################"
environment "" ""
environment "PATH" "1"
environment "LD_LIBRARY_PATH" "1"
environment "CUDA_PATH" "1"
environment "" ""
environment "http_proxy" "1"
environment "https_proxy" "1"
environment "HUGGING_FACE_TOKEN" "0"

################################################################

echo "正在拉取依赖项"
log "正在拉取依赖项" 

cd $FDK_DIR
git submodule update --init --recursive

echo
echo "################################################################"

echo
echo "正在配置镜像源"
log
log "正在配置镜像源" 

PYTHON_DIR="$ENVIRONMENT_DIR/bin/python3"
PIP_DIR="$ENVIRONMENT_DIR/bin/pip3"
DEPENDENT_DIR="$FDK_DIR/Dependent"

echo
$PIP_DIR install --upgrade pip --index-url "$PYPI_MIRROR"
echo
echo "镜像源配置完成50%"
log "镜像源配置完成50%" 
echo
$PIP_DIR config set global.index-url "$PYPI_MIRROR"
echo

echo
echo "################################################################"

echo
echo "正在配置编译库"
log
log "正在配置编译库" 

echo
$PIP_DIR install torch torchvision torchaudio
echo
echo "编译库配置完成50%"
echo
log "编译库配置完成50%" 
echo
$PIP_DIR install packaging ninja cpufeature numpy

echo
echo "################################################################"

echo
echo "正在配置依赖项"
log
log "正在配置依赖项" 

echo
$PIP_DIR install --upgrade huggingface_hub
echo
echo "依赖项配置完成5%"
log "依赖项配置完成5%" 
echo
$PIP_DIR install open-webui
echo
echo "依赖项配置完成15%"
log "依赖项配置完成15%" 
echo
$PIP_DIR install nicegui
echo
echo "依赖项配置完成25%"
log "依赖项配置完成25%" 

echo
$PIP_DIR install -v $DEPENDENT_DIR/GPTQModel --no-build-isolation
echo
echo "依赖项配置完成35%"
log "依赖项配置完成35%" 
echo
$PIP_DIR install autoawq
echo
echo "依赖项配置完成45%"
log "依赖项配置完成45%" 
echo
$PIP_DIR install -r $DEPENDENT_DIR/llmc/requirements.txt
echo
echo "依赖项配置完成55%"
log "依赖项配置完成55%" 
echo
$PIP_DIR install -e $DEPENDENT_DIR/lm-evaluation-harness
echo
echo "依赖项配置完成65%"
log "依赖项配置完成65%" 
echo
$PIP_DIR install --upgrade "evalplus[perf,vllm] @ git+https://github.com/evalplus/evalplus"
echo
echo "依赖项配置完成75%"
log "依赖项配置完成75%" 
echo
$PIP_DIR install "opencompass[full]"
echo
echo "依赖项配置完成85%"
log "依赖项配置完成85%" 
echo
$PIP_DIR install vllm
echo
echo "依赖项配置完成95%"
log "依赖项配置完成95%" 
echo
$PIP_DIR install "sglang[all]"
echo

echo
echo "################################################################"
log
log "################################################################"

################################################################