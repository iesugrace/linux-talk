一、测试环境变量的作用范围
1. 创建一个简单的脚本，文件名为env.sh，输入虚线之间的内容
[czl@mob ~]$ nano env.sh
----------------------------
#!/bin/bash
echo "v: $v"
----------------------------

2. 给脚本加上可执行权限
[czl@mob ~]$ chmod +x env.sh

3. 执行脚本，观看输出
[czl@mob ~]$ ./env.sh
v:                      <-- 冒号后面没有内容

4. 设定一个普通变量
[czl@mob ~]$ v=hello

5. 再次执行脚本env.sh, 观看输出
[czl@mob ~]$ ./env.sh
v:                      <-- 冒号后面仍然没有内容

6. 把第4步的变量输出成环境变量
[czl@mob ~]$ export v

7. 再次执行脚本env.sh, 观看输出
[czl@mob ~]$ ./env.sh
v: hello                <-- 冒号后面可以看到变量的内容

8. 把变量v删除
[czl@mob ~]$ unset v

9. 再次执行脚本env.sh, 观看输出
[czl@mob ~]$ ./env.sh
v:                      <-- 冒号后面的内容又没有了

10. 用以下方式执行脚本，观看输出：
[czl@mob ~]$ v="tmp env" ./env.sh
v: tmp env              <-- 临时设置一个环境变量给脚本

11. 查看是否存在一个名为 v 的变量
[czl@mob ~]$ echo $v    <-- 不存在名为v 的变量





二、修改密码时不用手动输入密码，有两种方法
1. 创建一个密码文件password_data，在里面输入两次新的密码，然后把该文件作为passwd 命令的标准输入
[root@mob ~]$ echo abc > password_data
[root@mob ~]$ echo abc >> password_data
[root@mob ~]$ passwd username < password_data

2. 通过管道的方式提供密码，passwd 命令接一个--stdin 的参数
[root@mob ~]$ echo "password" | passwd --stdin username





三、验证进程的标准输入输出所连接的文件
1. 在一个终端运行命令
[czl@mob ~]$ sleep 999 1> /tmp/good 2>&1

2. 在另外一个终端，找出sleep 的进程ID，假设PID 为14312
[root@mob ~]# pgrep -x sleep
14312

3. 查看该进程所打开的文件
[root@mob ~]# lsof -a -nP -p14312 -d0,1,2
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
sleep   14312  czl    0u   CHR  136,8      0t0   11 /dev/pts/8
sleep   14312  czl    1w   REG  253,3        0  110 /tmp/good
sleep   14312  czl    2w   REG  253,3        0  110 /tmp/good





四、修改测试程序 programs/io.c、编译、运行，验证程序在使用输入输出时的选择性
1. 编译程序，如果提示缺少编译器，就用右列命令安装yum install "@development tools"
[czl@mob ~]$ gcc io.c

2. 运行程序
[czl@mob ~]$ ./a.out 
Enter something: 123    <-- 输入三个字符
123                     <-- 程序输出刚刚输入的字符
Need more characters.   <-- 字符不足10个，所以有错误信息输出

3. 屏蔽标准错误
[czl@mob ~]$ ./a.out 2> /dev/null
Enter something: 123
123
                        <-- 这里看不到错误信息了

4. 修改程序的原文件，删掉第33 和 第38 行中的两个注释符号，也就是把以下代码：
    /*                  <-- 删除此行
    int fd = open("/dev/tty", O_RDWR);
    in_fd = fd;
    out_fd = fd;
    err_out_fd = fd;
    */                  <-- 删除此行

    变成

    int fd = open("/dev/tty", O_RDWR);
    in_fd = fd;
    out_fd = fd;
    err_out_fd = fd;

5. 再次编译程序
[czl@mob ~]$ gcc io.c

6. 再次运行程序，屏蔽标准错误
[czl@mob ~]$ ./a.out 2> /dev/null
Enter something: 123
123
Need more characters.     <-- 错误信息依然存在

结论：shell 自动打开的标准输入，标准输出，标准错误，只是为程序提供了一种使用上的选择，并没有强制性。程序可以不使用这三个标准的输入输出。当程序使用自定义的输入输出时，就不能通过通常的重定向来屏蔽错误信息了。








五、如何运行一个登录shell (login shell)？
可以用以下方式运行一个登录shell
1. 通过命令 bash --login
2. 通过命令su - [username]
3. 在文本控制台登录
4. 编译运行程序 programs/shell.c，当第一个参数以连字符(-) 开头时，打开的就是登录shell
5. 运行 programs/shell.py，与shell.c 程序效果相同，只是不需要编译，而且支持多个参数

因为只有登录shell 才会读取~/.bash_profile 文件，所以可以这样测试：在该文件中添加一个变量，然后在启动的新shell 中检验该变量的值。

1. 在~/.bash_profile 中添加一个标记
[czl@mob ~]$ echo 'v="login shell"' >> ~/.bash_profile

2. 运行命令bash --login，然后检查变量v
[czl@mob ~]$ bash --login
[czl@mob ~]$ echo $v
login shell                 <-- 有变量v，说明是登录shell

3. 运行命令 su - <当前用户名>
[czl@mob ~]$ su - czl       <-- czl 是一个用户名，请按各自情况修改
Password: 
[czl@mob ~]$ echo $v
login shell                 <-- 有变量v，说明是登录shell

4. 用Ctrl+Alt+F2 进入第二个控制台，通常就是文本控制台，登录，然后检查变量v 是否存在

5. 编译程序shell.c，并运行
[czl@mob ~]$ gcc shell.c    <-- 编译将会生成一个名为a.out 的可执行文件
[czl@mob ~]$ ./a.out -      <-- 程序带一个减号做参数
[czl@mob ~]$ echo $v
login shell                 <-- 有变量v，说明是登录shell
[czl@mob ~]$ ./a.out        <-- 程序不带参数
[czl@mob ~]$ echo $v
                            <-- 没有变量v，说明不是登录shell

6. 直接运行 shell.py
[czl@mob ~]$ chmod +x shell.py
[czl@mob ~]$ ./shell.py -xx     <-- 参数以减号开头，是登录shell
[czl@mob ~]$ ./shell.py -bash   <-- 同上






六、实现在用户登出时自动保存其命令历史到某个文件
1. 在配置文件.bash_profile中清除旧的历史命令，这个时候旧的历史记录还没有加载，删掉它可以避免把旧的命令历史加载到当前shell中
[czl@mob ~]$ vi ~/.bash_profile
rm -f ~/.bash_history     <-- 在文件的末尾添加这条命令

2. 在配置文件.bash_logout中加入保存历史命令的命令
[czl@mob ~]$ vi ~/.bash_logout
history -w "$HOME/.history/history_$(date +'%Y%m%d%H%M%S).txt"

3. 第二步中所添加的命令将会把历史命令保存到家目录下的.history 目录中，但是该目录还不存在，所以需要创建
[czl@mob ~]$ mkdir ~/.history






七、测试文件 ~/.bash_logout 被读取的时机
1. 在~/.bash_logout 中添加一条命令，比如说：
[czl@mob ~]$ vi ~/.bash_logout
echo "logout from a login shell"    <-- 在末尾添加一条命令

2. 打开一个login shell
[czl@mob ~]$ bash --login

3. 退出第二步的shell 时，应该能够看到"logout from a login shell"
[czl@mob ~]$ exit
logout
logout from a login shell           <-- 能够看到之前设置的字符串

4. 打开一个非login shell
[czl@mob ~]$ bash

5. 退出第四步的shell 时，看不到之前设置的信息
[czl@mob 03_advanced_in_basic]$ exit
exit







八、要求所有用户登录的时候，自动设置一个环境变量TMOUT=10，使得用户在10秒内无输入，就自动退出。注意，该环境变量应该设成只读，防止用户修改，使用命令 help declare 可以查到设置只读变量的方法。

[root@mob ~]# vi /etc/profile
declare -r TMOUT=60             <-- 在最后添加这条命令即可







九、验证重定向发生的时机

1. 文件file 的内容如下
[czl@mob ~]$ cat file 
12345
abcde

2. 只保留文件的前面5行 （错误的操作，数据丢失）
[czl@mob ~]$ wc -l file
36 file
[czl@mob ~]$ head -n5 file > file
[czl@mob ~]$ wc -l file 
0 file                      <-- 文件file 变为空，和预期的不一样。

原因：shell 执行命令之前，会先执行重定向操作，在上面的命令中，就是 > file，这个重定向操作会把文件file 的内容清空。当重定向操作把file 文件清空之后，再head 该文件，也只能得到空了。


下面的例子中，用户没有机会输入密码，因为重定向操作先执行，当前用户是普通用户，无法在路径 /root/ls.log 中创建文件，shell 出错并退出，此时还没有执行命令sudo，所以也就没有机会输入密码。
[czl@mob ~]$ sudo ls /root > /root/ls.log
bash: /root/ls.log: Permission denied







十、管道练习
1. 计算/etc/passwd 文件的总行数
[czl@mob ~]$ cat /etc/passwd | wc -l

2. 查看所有用户中，有多少用户的登录shell 是bash
[czl@mob ~]$ cat /etc/passwd | grep bash | wc -l

3. 默认情况下，写到标准错误的数据不会流经管道，如果需要使标准错误的数据流经管道，就需要做相应的重定向。用普通用户运行以下三条命令，体会其不同的结果：
    ls /home | cat > /dev/null
    ls /home /root | cat > /dev/null
    ls /home /root 2>&1 | cat > /dev/null





十一、默认情况下，在/etc/bashrc 和 ~/.bashrc 中设置的变量，会出现在登录shell 和交互shell 中。如果需要在这两个文件中设置某个变量，而又希望该变量不会出现在登录shell 中，可以如何操作？默认的配置中，登录shell，交互shell 与所读取的配置文件之间的关系如下：

          login shell                    interactive shell
             /  \                                |
            /    \                               |
         1 /      \ 2                            |
          /        \                             |
         /          \                            v
/etc/profile       ~/.bash_profile  ----->  ~/.bashrc  -----> /etc/bashrc

实验目标：
在~/.bashrc 中设置一个变量：v，要求该变量只出现在交互shell中

参考步骤：
1. 在~/.bash_profile 的 **[适当位置]** 添加一个标记
LOGINSHELL=1            <-- 添加一个变量，用以标识shell 是否登录shell

2. 在添加所需的变量的时候，先做一个判断，当不是登录shell 时，才设置变量
if [ "$LOGINSHELL" != 1 ];then
    v="interactive shell only"
fi




十二、 验证别名、函数、内部命令、外部命令的优先级别
1. 创建一个命令别名 pwd 
alias pwd='echo it is an alias'

2. 创建一个名为 pwd 的函数
function pwd() { echo "this is a function"; }

3. 运行命令 pwd，查看输出
4. 删除别名，再次运行命令 pwd，查看输出
   unalias pwd 
5. 删除函数，再次运行命令 pwd，查看输出
   unset pwd 
6. 以路径的方式运行外部命令 pwd 
   /bin/pwd
