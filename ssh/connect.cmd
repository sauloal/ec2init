set PORT=22
set KEY=keys\guest.ppk
set USR=guests
set ADD=aws.sauloal.x64.me
set FWD=-L 127.0.0.2:9999:127.0.0.1:9999 -L 127.0.0.2:8080:127.0.0.1:8080 -L 127.0.0.2:80:127.0.0.1:80 -L 127.0.0.2:3260:127.0.0.1:3260 -L 127.0.0.2:135:127.0.0.1:135 -L 127.0.0.2:111:127.0.0.1:111 -L 127.0.0.2:2049:127.0.0.1:2049 -L 127.0.0.2:137:127.0.0.1:137 -L 127.0.0.2:139:127.0.0.1:139 -L 127.0.0.2:445:127.0.0.1:445 -L 127.0.0.2:138:127.0.0.1:138 -L 127.0.0.2:32803:127.0.0.1:32803 -L 127.0.0.2:32769:127.0.0.1:32769 -L 127.0.0.2:892:127.0.0.1:892 -L 127.0.0.2:875:127.0.0.1:875 -L 127.0.0.2:662:127.0.0.1:662 -L 127.0.0.2:2020:127.0.0.1:2020 -L 127.0.0.2:4000:127.0.0.1:4000 -L 127.0.0.2:47137:127.0.0.1:47137 -L 127.0.0.2:44250:127.0.0.1:44250 -L 127.0.0.2:20048:127.0.0.1:20048 -L 127.0.0.2:860:127.0.0.1:860 -L 127.0.0.2:443:127.0.0.1:443 -L 127.0.0.2:8888:127.0.0.1:8888  -L 127.0.0.2:873:127.0.0.1:873

set CMD="plink.exe -ssh -N -A -x -T -C -2 -4 -batch -P %PORT% -i %KEY% -l %USR% %FWD% %ADD%"

echo CMD %CMD%

rem #-X -x     enable / disable X11 forwarding
rem #-A -a     enable / disable agent forwarding
rem #-t -T     enable / disable pty allocation
rem #-1 -2     force use of particular protocol version
rem #-4 -6     force use of IPv4 or IPv6
rem #-C        enable compression
rem #-N        don't start a shell/command (SSH-2 only)

rem # -L 127.0.0.2:10000:127.0.0.1:10000 
