# 使用golang:alpine作为基础镜像，这个镜像比较轻量且包含了Go语言环境
# 作用就是告诉docker使用那个基础镜像作为模板，后续命令都一这个镜像作为基础
FROM golang:alpine AS builder

# 为我们的镜像设置必要的环境变量
# 为我们的镜像设置必要的环境变量
ENV GO111MODULE=on \
GOPROXY=https://goproxy.cn,direct \
CGO_ENABLED=0 \
GOOS=linux \
GOARCH=amd64
# 设置中国的代理

# 创建工作目录：/build
WORKDIR /build

# 复制项目中的 go.mod 和 go.sum文件并下载依赖信息
COPY go.mod .
COPY go.sum .
RUN go mod download

# 将代码复制到容器中
COPY .. .

# 将我们的代码编译成二进制可执行文件 MyApp
RUN go build -o Newstudy .


###################
# 接下来创建一个小镜像
###################
# 第二阶段（如果需要访问config.yaml，则此阶段不适用scratch，因为scratch不包含文件系统）
# FROM scratch
# 由于scratch不包含文件系统，以下COPY指令将无效
# COPY --from=builder /build/MyApp /MyApp
# COPY --from=builder /path/in/image/config.yaml /config.yaml  # 这也会失败

# 替代方案：选择一个包含文件系统的基础镜像
#FROM alpine:latest
FROM debian:stretch-slim


# 从builder镜像中把可执行文件拷贝到当前目录 /build/Newstudy <- /Newstudy
COPY --from=builder /build/Newstudy /

# 设置运行时的工作目录（可选，如果MyApp需要访问相对路径的文件）
# WORKDIR /root

COPY /config.yaml /config.yaml

# 声明服务端口
EXPOSE 8080

# 告诉docker，启动容器时执行如下命令
#CMD []

# 设置入口点
ENTRYPOINT ["/Newstudy","config.yaml"]
# 如果MyApp需要特定参数，可以在这里添加，例如：ENTRYPOINT ["/MyApp", "-config", "/config/myapp.conf"]
# 注意：由于我们使用的是scratch镜像，所以这里必须确保MyApp是静态链接的，或者所有必要的库都已经以某种方式包含在镜像中。
# 否则，MyApp可能无法运行