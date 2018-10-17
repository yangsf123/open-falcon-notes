# 单机版安装

## 环境准备
- Git >= 1.7.5
- Go >= 1.6

## Getting Started

### Build from source
- redis安装
    `yum install -y redis`

- 下载并安装MySQL官方的Yum Repository
    `wget -i -c http://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm`
    `wget -i -c http://dev.mysql.com/get/mysql-community-server-8.0.12-1.el7.x86_64.rpm`
    `yum -y install mysql80-community-release-el7-1.noarch.rpm`
    `yum -y install mysql-community-server`

- 启动redis,mysql
    `redis-server`
    `systemctl start mysqld.service`
    `systemctl status mysqld.service`

- 获取mysql初始密码并登录
    `grep "password" /var/log/mysqld.log`
    `mysql -uroot -p`

    brew services stop mysql 之后 就可以终止mysqld进程了。 如果用mysql.server stop 或者用kill 都是不能终止mysqld这个进程的。即使终止了，过一会就又会出现

- 重置密码
    `alter user 'root'@'localhost' identified by 'Paic$3@1';`

- mysql完整初始密码规则查看
    `show variables like 'validate_password%'`;

- remove rpm
    `yum -y remove mysql80xxx.noarch`

- open-falcon
    `mkdir -p $GOPATH/src/github.com/open-falcon`
    `cd $GOPATH/src/github.com/open-falcon`
    `git clone https://github.com/open-falcon/falcon-plus.git`

- 初始化数据库
    `cd $GOPATH/src/github.com/open-falcon/falcon-plus/scripts/mysql/db_schema/`
    `mysql -h 127.0.0.1 -u root -p < 1_uic-db-schema.sql`
    `mysql -h 127.0.0.1 -u root -p < 2_portal-db-schema.sql`
    `mysql -h 127.0.0.1 -u root -p < 3_dashboard-db-schema.sql`
    `mysql -h 127.0.0.1 -u root -p < 4_graph-db-schema.sql`
    `mysql -h 127.0.0.1 -u root -p < 5_alarms-db-schema.sql`

    如果是从v0.1升级到v0.2.0执行: `mysql -h 127.0.0.1 -u root -p < 5_alarms-db-schema.sql`

- 编译
    `cd $GOPATH/src/github.com/open-falcon/falcon-plus/`
    
    # make all modules
    `make all`

    # make specified module
    `make agent`

    # pack all modules
    `make pack`

    - 编译之后会得到open-falcon-vx.x.x.tar.gz
    - 如果你想针对每个模块编辑配置文件，你可以在打包之前编辑config/xxx.json

- 解包和分解
    `export WorkDir="$HOME/open-falcon"`
    `mkdir -p $WorkDir`
    `tar -xzvf open-falcon-vx.x.x.tar.gz -C $WorkDir`
    `cd $WorkDir`

- Start all modules in single host
    `cd $WorkDir`
    `./open-falcon start`
    `./open-falcon check`

- Run more open-falcon commands
    `./open-falcon [start|stop|restart|check|monitor|reload] module`

### Install Frontend Dashboard
- 
