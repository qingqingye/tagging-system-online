FROM python:3.6
#3.6不用声明系统是ubuntu还是Windows ，python36可以跨平台
ENV PYTHONUNBUFFERED 1
RUN apt-get update && \ DEBIAN_FRONTEND=noninteractive apt-get -yq install sqlite3 &&
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#run后面是你要安装的东西 可以理解为在镜像里面run了这个指令
#可以把需要安装的包全部声明在requirement.txt里面也可以 run 一个个安装
RUN mkdir /code
#在你的镜像里创造一个文件夹
WORKDIR /code
#把镜像的工作地址设置为那个文件夹
ADD requirements.txt /code/
#把主机上的 requirement.txt添加到刚刚创立的文件夹里面
RUN pip install -r requirements.txt #运行根据requirement.txt安装
ADD . /code/
#把当前目录的内容添加到code文件夹里
