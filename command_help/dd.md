# dd

## count=N

copy only `N` input blocks

## seek=N

skip `N` obs-sized blocks at start of output

## skip=N

skip `N` ibs-sized blocks at start of input

## bs=BYTES

read and write up to `BYTES` bytes at a time (default: 512);
                  overrides ibs and obs

## ibs=BYTES

read up to `BYTES` bytes at a time (default: 512)

## obs=BYTES

write `BYTES` bytes at a time (default: 512)

## cbs=BYTES

convert `BYTES` bytes at a time
  
## conv=CONVS

convert the file as per the comma separated symbol list

## if=FILE

read from FILE instead of stdin

## iflag=FLAGS

read as per the comma separated symbol list

## of=FILE

write to `FILE` instead of stdout

## oflag=FLAGS

write as per the comma separated symbol list

## status=LEVEL

The LEVEL of information to print to stderr;

- 'none' suppresses everything but error messages,
- 'noxfer' suppresses the final transfer statistics,
- 'progress' shows periodic transfer statistics
