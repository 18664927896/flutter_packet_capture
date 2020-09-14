# flutter_packet_capture

解决flutter项目抓包问题
## Getting Started
```
flutter_packet_capture:
```

```
//scheme配置
Packetcapture.setConfig(schemeConfig: 'capture://',modeConfig: "debug");
  Packetcapture.initUniLinks(callBack: (hostPort){
    //设置代理
    Network.setHttpProxy(hostPort);
  });
```

## 使用方法
>1，注册自己的URL Scheme，例如：scheme://
>2，定义参数规则，例如：scheme://xxxx?host=10.0.206.163&port=8888 (port可不要，默认8888)
>3，使用[草料](https://cli.im)生成一个二维码：内容：scheme://xxxx?host=191.101.206.163 ；
> 4，用原相机扫描二维码，打开app就可以抓包了；
