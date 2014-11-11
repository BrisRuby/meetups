#!/usr/sbin/dtrace -Zs
/* count ruby/C method calls */
#pragma D option quiet

ruby*:::method-entry
/pid == $target/
{
	@methods[strjoin(strjoin(copyinstr(arg0), "::"), copyinstr(arg1))] = count();
	@sources[copyinstr(arg2)] = count();
}

ruby*:::cmethod-entry
/pid == $target/
{
	@methods[strjoin(strjoin(copyinstr(arg0), "::"), copyinstr(arg1))] = count();
	@sources[copyinstr(arg2)] = count();
}

