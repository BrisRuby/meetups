#pragma D option quiet

self int tracking;

dtrace:::BEGIN
{
	printf("Tracing... Hit Ctrl-C to end.\n");
	self->tracking = 0;
}

mattcustom*:::action-begin
{
	self->tracking = pid;
}

mattcustom*:::action-end
{
	self->tracking = 0;
}

ruby*:::method-entry
/self->tracking == pid/
{
	this->name = strjoin(strjoin(copyinstr(arg0), "::"), copyinstr(arg1));
	@calls[this->name] = count();
/*	printf("%s\n", this->name); */
}

ruby*:::cmethod-entry
/self->tracking == pid/
{
	this->name = strjoin(strjoin(copyinstr(arg0), "::"), copyinstr(arg1));
	@calls[this->name] = count();
/*	printf("%s\n", this->name); */
}

dtrace:::END
{
	printf(" %8s %-40s\n", "COUNT", "CALLS TO METHOD");
	printa(" %@8d %-40s\n", @calls);
}