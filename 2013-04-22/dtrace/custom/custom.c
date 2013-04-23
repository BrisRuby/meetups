#include <stdio.h>
#include "custom.h"
#include "custom_probes.h"

int matt_custom_action_begin(const char* string)
{
	if (MATTCUSTOM_ACTION_BEGIN_ENABLED()) {
		MATTCUSTOM_ACTION_BEGIN(string);
	}
	printf("matt_custom_action_begin('%s')\n", string);
	return 1;
}

int matt_custom_action_end()
{
	if (MATTCUSTOM_ACTION_END_ENABLED()) {
		MATTCUSTOM_ACTION_END();
	}
	printf("matt_custom_action_end\n");
	return 2;
}
