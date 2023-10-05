# BashProfiling

> I know it is a horrible name but it is working for me.

If you want to try it you have to have a linux sistem with `/proc` file system.

## Usage
- Download
```git clone https://github.com/develooper1994/ProcPIDStat_profiling```
- Give the permission.
```chmod +x cpusage.sh```
- Run with a process
```cpusage.sh <PID> <logfile>```
### Example
1. ```cpusage.sh 512 log.txt```
2. ```cpusage.sh $(pidof bash) log_bash.txt```
