# iGraffiti
### 应用介绍
用户可以通过在墙上涂鸦的方式实现与他人交流分享信息。

涂鸦墙总共分为三类：

* 公众涂鸦墙：任何非注册用户都可以查看并在上面涂鸦的涂鸦墙。通过此墙实现公众社交功能。
* 告示涂鸦墙：任何非注册用户都可以查看该涂鸦墙的内容，但只有墙的创建者才可以在墙面上进行涂鸦。通过该墙可实现信息发布功能。
* 私人涂鸦墙：任何非注册用户都可以通过密码访问或修改该墙。通过该墙实现私人交流的功能。

注册用户可以创建、收藏任意种类的涂鸦墙，或是将任意涂鸦墙加入通知列表，来第一时间得知涂鸦墙内容更新。

### 应用设计思路
通过Manager类来实现对Model的管理与维护，所有网络请求在Manager中实现，Controller层只与Manager类进行通信，把相应任务交给Manager类，Manager类执行Controller层接收到的任务，并将执行成功失败等消息反馈给相应Controller。
其中WallManager类通过状态机来实现控制，确保各个状态所用资源不会出现错误竞争。如，绘图状态，上传图像状态，更新涂鸦墙状态等。

### 涂鸦功能的实现
从服务器获取墙面图像，将其等比例变换为各种设备屏幕适合的大小。通过手势及UIView的draw方法来实现绘制涂鸦，在将涂鸦上传至服务器前，再将涂鸦等比例变换回原涂鸦墙的尺寸。
