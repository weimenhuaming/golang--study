package main

import (
	"Newstudy/Web_backend/config"
	"Newstudy/Web_backend/dao/mysql"
	"Newstudy/Web_backend/dao/redis"
	"Newstudy/Web_backend/globals"
	"Newstudy/Web_backend/logger"
	"Newstudy/Web_backend/routers"
	"fmt"
)

func main() {
	// 加载配置文件
	if err := config.InitConfig(); err != nil {
		fmt.Printf("init config failed,err :%v\n", err)
		return
	}

	// 加载日志库
	log, err := logger.InitLogger(config.AppConfig.Logger.Std, config.AppConfig.Logger.Level)
	globals.Lg = log // 将这个对象赋值给全局lg对象
	if err != nil {
		fmt.Printf("init logger failed,err :%v\n", err)
		return
	}

	// 加载mysql数据库
	sqlDb, err1 := mysql.InitMysqlDb()
	if err1 != nil {
		fmt.Printf("init mysql db failed,err:%v\n", err1)
		return
	}
	defer sqlDb.Close()

	// 加载redis数据库
	Rdb, err2 := redis.InitRedis()
	if err2 != nil {
		fmt.Printf("init redis failed,err:%v\n", err2)
		return
	}
	defer Rdb.Close()

	fmt.Println("true")
	// 注册路由
	r := routers.SetupRouter(config.AppConfig.Server.Mode)
	err = r.Run(config.AppConfig.Server.HttpPort)
	if err != nil {
		fmt.Printf("run server error:%v\n", err)
	}
}
