# Powered by QiGao
# Copyright 2025- alkali. All Rights Reserved.
################################################################

FDK_VERSION="0.1"
FDK_VERSION_TYPE="Developer_Beta"
PYTHON_VERSION="3.12.7"
PYPI_MIRROR="https://mirrors.sustech.edu.cn/pypi/web/simple"
HF_ENDPOINT="https://hf-mirror.com"

################################################################

echo "FPGA-Deployment-Kit 开发工具包部署工具"
echo "Powered by QiGao"
echo "Copyright 2025- alkali. All Rights Reserved."
echo
echo "################################################################"
echo
echo "                  $$\ $$\                $$\ $$\         "
echo "                  $$ |$$ |               $$ |\__|        "
echo "         $$$$$$\  $$ |$$ |  $$\ $$$$$$\  $$ |$$\         "
echo "         \____$$\ $$ |$$ | $$  |\____$$\ $$ |$$ |        "
echo "         $$$$$$$ |$$ |$$$$$$  / $$$$$$$ |$$ |$$ |        "
echo "        $$  __$$ |$$ |$$  _$$< $$  __$$ |$$ |$$ |        "
echo "        \$$$$$$$ |$$ |$$ | \$$\\$$$$$$$ |$$ |$$ |        "
echo "         \_______|\__|\__|  \__|\_______|\__|\__|        "
echo
echo "################################################################"
echo

while true; do
    read -p "键入 y 继续部署进程：" choice
    case ${choice,,} in
        y)
            break
            ;;
        n)
            echo "放弃部署，所有可逆操作已撤销"
            exit 0
            ;;
        *)
            echo "无效输入"
            ;;
    esac
done

################################################################

echo "正在初始化部署环境"

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
FDK_DIR="$(realpath "$SCRIPT_DIR/../..")"
PARENT_DIR="$(realpath "$FDK_DIR/..")"

ENVIRONMENT_FILE="$FDK_DIR/.env"
GIT_IGNORE_FILE="$FDK_DIR/.gitignore"
GIT_MODULES_FILE="$FDK_DIR/.gitmodules"

echo
if [ -d "$PARENT_DIR/Repositories" ]; then
    echo "使用现有存储库"
else
    echo "正在创建存储库"
    mkdir -p "$PARENT_DIR/Repositories"
fi

REPOSITORIES_DIR=$PARENT_DIR/Repositories

#if [ ! -d "$REPOSITORIES_DIR/Bitstreams" ]; then
#    mkdir -p "$REPOSITORIES_DIR/Bitstreams"
#fi
#if [ ! -d "$REPOSITORIES_DIR/Datasets" ]; then
#    mkdir -p "$REPOSITORIES_DIR/Datasets"
#fi
#if [ ! -d "$REPOSITORIES_DIR/Evaluations" ]; then
#    mkdir -p "$REPOSITORIES_DIR/Evaluations"
#fi
#if [ ! -d "$REPOSITORIES_DIR/Models" ]; then
#    mkdir -p "$REPOSITORIES_DIR/Models"
#fi
#if [ ! -d "$REPOSITORIES_DIR/Quantifications" ]; then
#    mkdir -p "$REPOSITORIES_DIR/Quantifications"
#fi
#if [ ! -d "$REPOSITORIES_DIR/Services" ]; then
#    mkdir -p "$REPOSITORIES_DIR/Services"
#fi
#if [ ! -d "$REPOSITORIES_DIR/Weights" ]; then
#    mkdir -p "$REPOSITORIES_DIR/Weights"
#fi

################################################################

if [ -d "$REPOSITORIES_DIR/Backups" ]; then
    echo "使用现有备份库"
else
    echo "正在创建备份库"
    mkdir -p "$REPOSITORIES_DIR/Backups"
fi

BACKUPS_DIR="$REPOSITORIES_DIR/Backups"

#if [ ! -d "$BACKUPS_DIR/.env" ]; then
#    mkdir -p "$BACKUPS_DIR/.env"
#fi

if [ ! -d "$BACKUPS_DIR/AutoBackups" ]; then
    mkdir -p "$BACKUPS_DIR/AutoBackups"
fi

AUTO_BACKUPS_DIR="$BACKUPS_DIR/AutoBackups"

#if [ ! -d "$BACKUPS_DIR/Bitstreams" ]; then
#    mkdir -p "$BACKUPS_DIR/Bitstreams"
#fi
#if [ ! -d "$BACKUPS_DIR/Datasets" ]; then
#    mkdir -p "$BACKUPS_DIR/Datasets"
#fi
#if [ ! -d "$BACKUPS_DIR/Environment" ]; then
#    mkdir -p "$BACKUPS_DIR/Environment"
#fi
#if [ ! -d "$BACKUPS_DIR/Evaluations" ]; then
#    mkdir -p "$BACKUPS_DIR/Bitstreams"
#fi
#if [ ! -d "$BACKUPS_DIR/Logs" ]; then
#    mkdir -p "$BACKUPS_DIR/Logs"
#fi
#if [ ! -d "$BACKUPS_DIR/Models" ]; then
#    mkdir -p "$BACKUPS_DIR/Models"
#fi
#if [ ! -d "$BACKUPS_DIR/Quantifications" ]; then
#    mkdir -p "$BACKUPS_DIR/Quantifications"
#fi
#if [ ! -d "$BACKUPS_DIR/Services" ]; then
#    mkdir -p "$BACKUPS_DIR/Services"
#fi
#if [ ! -d "$BACKUPS_DIR/Weights" ]; then
#    mkdir -p "$BACKUPS_DIR/Weights"
#fi

################################################################

if [ -d "$REPOSITORIES_DIR/Logs" ]; then
    echo "使用现有日志库"
else
    echo "正在创建日志库"
    mkdir -p "$REPOSITORIES_DIR/Logs"
fi

LOGS_DIR="$REPOSITORIES_DIR/Logs"

#if [ ! -d "$LOGS_DIR/Bitstreams" ]; then
#    mkdir -p "$LOGS_DIR/Bitstreams"
#fi
#if [ ! -d "$LOGS_DIR/Datasets" ]; then
#    mkdir -p "$LOGS_DIR/Datasets"
#fi
#if [ ! -d "$LOGS_DIR/Evaluations" ]; then
#    mkdir -p "$LOGS_DIR/Bitstreams"
#fi
#if [ ! -d "$LOGS_DIR/Models" ]; then
#    mkdir -p "$LOGS_DIR/Models"
#fi
#if [ ! -d "$LOGS_DIR/Quantifications" ]; then
#    mkdir -p "$LOGS_DIR/Quantifications"
#fi
#if [ ! -d "$LOGS_DIR/Services" ]; then
#    mkdir -p "$LOGS_DIR/Services"
#fi
#if [ ! -d "$LOGS_DIR/Weights" ]; then
#    mkdir -p "$LOGS_DIR/Weights"
#fi

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
    echo "[ $(date +"%Y-%m-%d %H:%M:%S") ] $1" >> "$DEPLOYMENT_LOG_FILE"
}

echo
echo "正在初始化环境变量"
log
log "################################################################"
log
log "初始化环境变量" 

if [ -d "/usr/local/cuda" ]; then
    if [ -z "$CUDA_PATH" ]; then
        export CUDA_PATH="/usr/local/cuda"
    else
        export CUDA_PATH="$CUDA_PATH:/usr/local/cuda"
    fi
else
    echo "缺失必要依赖环境 CUDA，请手动安装，参见：https://developer.nvidia.com/cuda-downloads"
    log "缺失必要依赖环境 CUDA" 

    exit 1
fi
if [ -d "/usr/local/cuda/bin" ]; then
    export PATH="$PATH:/usr/local/cuda/bin"
else
    echo "必要依赖环境 CUDA 不完整，/usr/local/cuda/bin 不可达，请手动修复，参见：https://developer.nvidia.com/cuda-downloads"
    log "必要依赖环境 CUDA 不完整，/usr/local/cuda/bin 不可达" 

    exit 1
fi
if [ -d "/usr/local/cuda/lib64" ]; then
    if [ -z "$LD_LIBRARY_PATH" ]; then
        export LD_LIBRARY_PATH="/usr/local/cuda/lib64"
    else
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"
    fi
else
    echo "必要依赖环境 CUDA 不完整，/usr/local/cuda/lib64 不可达，请手动修复，参见：https://developer.nvidia.com/cuda-downloads"
    log "必要依赖环境 CUDA 不完整，/usr/local/cuda/lib64 不可达" 

    exit 1
fi

echo "检测到必要依赖环境 CUDA："
echo
nvcc -V
echo
echo "################################################################"

log "检测到必要依赖环境 CUDA："
log 
log "$(echo "$(nvcc -V)")"
log
log "################################################################"

################################################################

echo
echo "正在初始化虚拟化服务"
log
log "正在初始化虚拟化服务" 

if [ -d ~/anaconda3 ]; then
    echo "检测到必要依赖环境 Anaconda："
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
    echo "缺失必要依赖环境 Anaconda3，请先手动安装，参见：https://www.anaconda.com/download"
    log "缺失必要依赖环境 Anaconda3" 

    exit 1
fi

CONDA_DIR=~/anaconda3

################################################################

echo
echo "正在检测网络连通性"
log
log "正在检测网络连通性"

if ping -c 1 github.com &> /dev/null; then
    echo "网络连通性正常"
    log "网络连通性正常" 
else
    echo "网络连通性不良"
    log "网络连通性不良" 

    while true; do
        read -p "键入 y 使用代理：" choice
        log "键入 y 使用代理：$choice" 
        case ${choice,,} in
            y)
                break
                ;;
            n)
                echo "放弃部署，所有可逆操作已撤销"
                log "放弃部署，所有可逆操作已撤销" 

                exit 0
                ;;
            *)
                echo "无效输入"
                log "无效输入" 
                ;;
        esac
    done

    read -p "键入http代理地址：" input
    log "键入http代理地址：$input" 
    export http_proxy="$input"

    read -p "键入https代理地址：" input
    log "键入https代理地址：$input" 
    export https_proxy="$input"

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
    read -p "键入 y 使用 Hugging Face 镜像站：" choice
    log "键入 y 使用 Hugging Face 镜像站：$choice"
    case ${choice,,} in
        y)
            break
            ;;
        n)
            unset $HF_ENDPOINT
            break
            ;;
        *)
            echo "无效输入"
            log "无效输入" 
            ;;
    esac
done

read -p "键入 Hugging Face Token：" input
log "键入 Hugging Face Token：$input"

HUGGING_FACE_TOKEN="$input"
unset $input

echo
echo "################################################################"
log
log "################################################################"

################################################################

echo
echo "正在初始化虚拟化环境"
log
log "正在初始化虚拟化环境"

if [ -d ~/anaconda3/envs/FDK ]; then
    echo "检测到同名虚拟环境 FDK"
    log "检测到同名虚拟环境 FDK" 

    while true; do
        read -p "键入 y 覆盖：" choice
        log "键入 y 覆盖：$choice" 
        case ${choice,,} in
            y)
                echo
                echo "正在删除同名环境"
                log
                log "正在删除同名环境" 
                conda remove -n FDK --all -y

                break
                ;;
            n)
                echo
                echo "保留同名环境"
                read -p "键入其他的环境名称，如果键入 FDK 视作在该同名环境中部署：" input
                export ENVIRONMENT_DIR="$CONDA_DIR/envs/$input"
                log
                log "保留同名环境" 
                log "键入其他的环境名称，如果键入 FDK 视作在该同名环境中部署：$input" 
                
                if [ "$ENVIRONMENT_DIR" != "$CONDA_DIR/envs/FDK" ]; then
                    echo "正在部署虚拟化环境"
                    log "正在部署虚拟化环境" 
                    conda create -n $input python="$PYTHON_VERSION" -y
                else
                    echo "正在同名环境中部署"
                    log "正在同名环境中部署" 
                fi

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
    export ENVIRONMENT_DIR="$CONDA_DIR/envs/FDK"
fi

echo
echo "################################################################"
log
log "################################################################"

################################################################

echo
echo "安装 FDK 版本为 $FDK_VERSION，分类为 $FDK_VERSION_TYPE"
echo "正在初始化运行环境"
log
log "安装 FDK 版本为 $FDK_VERSION，分类为 $FDK_VERSION_TYPE" 
log "正在初始化运行环境" 

if [ -f "$ENVIRONMENT_FILE" ]; then
    echo "检测到环境中已有的环境变量文件"
    log "检测到环境中已有的环境变量文件" 

    while true; do
        read -p "键入 y 执行覆盖动作：" choice
        log "键入 y 执行覆盖动作：$choice" 
        case ${choice,,} in
            y)
                mkdir -p "$BACKUPS_DIR/Environment/$DATE"
                mv "$ENVIRONMENT_FILE" "$BACKUPS_DIR/Environment/$DATE/.env.$TIME.bk"
                export ENVIRONMENT_BACKUP_FILE="$BACKUPS_DIR/Environment/$DATE/.env.$TIME.bk"
                break
                ;;
            n)
                echo "放弃部署，所有可逆操作已撤销"
                log "放弃部署，所有可逆操作已撤销" 
                
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

PYTHON_DIR="$ENVIRONMENT_DIR/bin/python3"
PIP_DIR="$ENVIRONMENT_DIR/bin/pip3"
DEPENDENT_DIR="$FDK_DIR/Dependent"

################################################################

echo
echo "正在初始化环境变量"
log
log "正在初始化环境变量" 

echo "FDK_VERSION=$FDK_VERSION" > "$ENVIRONMENT_FILE"
echo "FDK_VERSION_TYPE=$FDK_VERSION_TYPE" >> "$ENVIRONMENT_FILE"
echo "PYTHON_VERSION=$PYTHON_VERSION" >> "$ENVIRONMENT_FILE"
echo "PYPI_MIRROR=$PYPI_MIRROR" >> "$ENVIRONMENT_FILE"
if [ -n "$HF_ENDPOINT" ]; then
    echo "HF_ENDPOINT=$HF_ENDPOINT" >> "$ENVIRONMENT_FILE"
fi

echo >> "$ENVIRONMENT_FILE"
echo "################################################################" >> "$ENVIRONMENT_FILE"
echo >> "$ENVIRONMENT_FILE"

echo "#DATE=$DATE" >> "$ENVIRONMENT_FILE"
echo "#TIME=$TIME" >> "$ENVIRONMENT_FILE"
echo "#DEPLOYMENT_LOG_FILE=$DEPLOYMENT_LOG_FILE" >> "$ENVIRONMENT_FILE"
if [ -n "$ENVIRONMENT_BACKUP_FILE" ]; then
    echo "#ENVIRONMENT_BACKUP_FILE=$ENVIRONMENT_BACKUP_FILE" >> "$ENVIRONMENT_FILE"
fi

echo >> "$ENVIRONMENT_FILE"
echo "################################################################" >> "$ENVIRONMENT_FILE"
echo >> "$ENVIRONMENT_FILE"

echo "SCRIPT_DIR=$SCRIPT_DIR" >> "$ENVIRONMENT_FILE"
echo "FDK_DIR=$FDK_DIR" >> "$ENVIRONMENT_FILE"
echo "PARENT_DIR=$PARENT_DIR" >> "$ENVIRONMENT_FILE"

echo >> "$ENVIRONMENT_FILE"

echo "ENVIRONMENT_FILE=$ENVIRONMENT_FILE" >> "$ENVIRONMENT_FILE"
echo "GIT_IGNORE_FILE=$GIT_IGNORE_FILE" >> "$ENVIRONMENT_FILE"
echo "GIT_MODULES_FILE=$GIT_MODULES_FILE" >> "$ENVIRONMENT_FILE"

echo >> "$ENVIRONMENT_FILE"

echo "REPOSITORIES_DIR=$REPOSITORIES_DIR" >> "$ENVIRONMENT_FILE"
echo "BACKUPS_DIR=$BACKUPS_DIR" >> "$ENVIRONMENT_FILE"
echo "AUTO_BACKUPS_DIR=$AUTO_BACKUPS_DIR" >> "$ENVIRONMENT_FILE"
echo "LOGS_DIR=$LOGS_DIR" >> "$ENVIRONMENT_FILE"

echo >> "$ENVIRONMENT_FILE"
echo "################################################################" >> "$ENVIRONMENT_FILE"
echo >> "$ENVIRONMENT_FILE"

echo "PATH=$PATH" >> "$ENVIRONMENT_FILE"
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> "$ENVIRONMENT_FILE"
echo "CUDA_PATH=$CUDA_PATH" >> "$ENVIRONMENT_FILE"

echo "CONDA_DIR=$CONDA_DIR" >> "$ENVIRONMENT_FILE"

echo >> "$ENVIRONMENT_FILE"
echo "################################################################" >> "$ENVIRONMENT_FILE"
echo >> "$ENVIRONMENT_FILE"

if [ -n "$http_proxy" ]; then
    echo "http_proxy=$http_proxy" >> "$ENVIRONMENT_FILE"
fi
if [ -n "$http_proxy" ]; then
    echo "https_proxy=$https_proxy" >> "$ENVIRONMENT_FILE"
fi

echo >> "$ENVIRONMENT_FILE"
echo "################################################################" >> "$ENVIRONMENT_FILE"
echo >> "$ENVIRONMENT_FILE"

echo "HUGGING_FACE_TOKEN=$HUGGING_FACE_TOKEN" >> "$ENVIRONMENT_FILE"

echo >> "$ENVIRONMENT_FILE"

echo "ENVIRONMENT_DIR=$ENVIRONMENT_DIR" >> "$ENVIRONMENT_FILE"
echo "PYTHON_DIR=$PYTHON_DIR" >> "$ENVIRONMENT_FILE"
echo "PIP_DIR=$PIP_DIR" >> "$ENVIRONMENT_FILE"
echo "DEPENDENT_DIR=$DEPENDENT_DIR" >> "$ENVIRONMENT_FILE"

echo "正在清理环境"
log "正在清理环境"
unset $ENVIRONMENT_DIR

################################################################

echo "正在拉取依赖项"
log "正在拉取依赖项" 
cd $FDK_DIR
git submodule update --init --recursive
echo
echo "################################################################"

echo
echo "正在配置镜像源"
log "正在配置镜像源" 

$PIP_DIR install --upgrade pip --index-url "$PYPI_MIRROR"
$PIP_DIR config set global.index-url "$PYPI_MIRROR"

echo
echo "################################################################"

echo
echo "正在安装编译库"
log "正在安装编译库" 

$PIP_DIR install torch torchvision torchaudio
$PIP_DIR install packaging ninja cpufeature numpy

echo
echo "################################################################"

echo
echo "正在安装依赖项"
log "正在安装依赖项" 

$PIP_DIR install --upgrade huggingface_hub
$PIP_DIR install nicegui

HUGGINGFACE_DIR="$ENVIRONMENT_DIR/bin/huggingface-cli"
echo "HUGGINGFACE_DIR=$HUGGINGFACE_DIR" >> "$ENVIRONMENT_FILE"

$PIP_DIR install -v $DEPENDENT_DIR/GPTQModel --no-build-isolation
$PIP_DIR install autoawq
$PIP_DIR install -r $DEPENDENT_DIR/llmc/requirements.txt
$PIP_DIR install -e $DEPENDENT_DIR/lm-evaluation-harness
$PIP_DIR install --upgrade "evalplus[perf,vllm] @ git+https://github.com/evalplus/evalplus"
$PIP_DIR install "opencompass[full]"
$PIP_DIR install vllm
$PIP_DIR install "sglang[all]"

echo
echo "################################################################"
log
log "################################################################"

################################################################