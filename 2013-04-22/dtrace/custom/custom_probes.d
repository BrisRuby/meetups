/*
#pragma D attributes Evolving/Evolving/Common provider mattcustom provider
#pragma D attributes Private/Private/Unknown provider mattcustom module
#pragma D attributes Private/Private/Unknown provider mattcustom function
#pragma D attributes Evolving/Evolving/Common provider mattcustom name
#pragma D attributes Evolving/Evolving/Common provider mattcustom args
*/

provider mattcustom {
	probe action__begin(const char *);
	probe action__end();
};
