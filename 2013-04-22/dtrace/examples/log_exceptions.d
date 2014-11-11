/* real time log exceptions. Prints exception name, source file name and line number. */
ruby*:::raise
{
  printf("'%s' at %s:%d", copyinstr(arg0), copyinstr(arg1), arg2);
}
