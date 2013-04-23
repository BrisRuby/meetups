#!/usr/sbin/dtrace -Zs

#pragma D option quiet

ruby*:::raise
/pid == $target/
{
  printf("'%s' at %s:%d\n", copyinstr(arg0), copyinstr(arg1), arg2);
}
