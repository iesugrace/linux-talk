/*
 * Autho: Joshua Chen
 * Date: Jun 2014
 * Location: Shenzhen
 * Description:
 * 使用系统调用read, write，测试标准输入输出0, 1, 2
 * 演示程序如何选择性地不使用标准的输入输出
 * 配合命令行重定向，观察结果
 */

#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>

int main(int argc, char **argv)
{
    char *prompt = "Enter something: ";
    char *errmsg = "Need more characters."; 
    unsigned char buf[1024];
    char in[1];
    int i = 0;
    int MINLEN = 5;

    // 使用Linux 的标准输入输出文件描述符
    int in_fd = 0;   // file descriptor
    int out_fd = 1;
    int err_out_fd = 2;

    /* 使用自定义的输入输出，而不是Linux 的标准输入输出文件描述符*/
    /*
    int fd = open("/dev/tty", O_RDWR);
    in_fd = fd;
    out_fd = fd;
    err_out_fd = fd;
    */

    // 输出提示信息
    write(out_fd, prompt, strlen(prompt));

    // 读取用户的输入
    while (read(in_fd, in, 1))
    {
        if (in[0] == '\n')
        {
            buf[i++] = 0;
            break;
        }
        buf[i++] = in[0];
    }

    // 输出刚刚获取的信息
    write(out_fd, buf, strlen(buf));
    write(out_fd, "\n", 1);

    // 输出错误信息
    if (strlen(buf) < MINLEN)
    {
        write(err_out_fd, errmsg, strlen(errmsg));
        write(err_out_fd, "\n", 1);
    }
}

