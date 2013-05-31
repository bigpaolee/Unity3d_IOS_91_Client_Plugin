Unity3d_IOS_91_Client_Plugin
============================

Unity3d_IOS_91_Client_Plugin

	本接口是91移动开放平台SDK,针对Unity3D接入相关API，进行的封装。具体API的参数，用法等请参照
SDK中的相关文档描述。Unity3D平台的API，去除U3d前缀后，同Native API命名一致。
在消息通知中，采用的key1=value1&key2=value2的格式封装多个参数为字符串，开发者需要按照这种格式
进行解析。详见【sendU3dMessage】等相关消息事件源码

//Plugins目录中文件拷贝到Xcode工程中的library文件夹中
//