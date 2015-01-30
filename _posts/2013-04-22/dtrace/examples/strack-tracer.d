#!/usr/sbin/dtrace

::::BEGIN
{
  printf("tracing...");
}

ruby*:::method-entry
{
  trace(strjoin(strjoin(copyinstr(arg0),"::"), copyinstr(arg1)));
}

profile-997
/arg0 && pid == $target/
{ 
  @[stack()] = count(); 
} 

tick-60s
{ 
  exit(0);
}
