## falcon-agent数据采集模块

- 监控数据来源
    机器的性能指标，cpu
    业务监控指标，比如某个接口调用的latency
    各种开源软件的状态指标，比如Nginx,Redis,MySQL等
    通过snmp采集的各种网络设备的相关指标
- 设计哲学
    支关注Linux本身的监控指标
    自发现各项采集值，无需服务端配置
    功能尽量简单，才能足够稳定
    尽量使用go代码实现，尽量不调用shell
    提供可扩展的机制
    操作一旦夯住，不重试
    不同类型数据的采集分成不同的goroutine
    对进程、端口监控的折中
- 配置文件介绍
    本机hostname,ip
- 代码组织结构

