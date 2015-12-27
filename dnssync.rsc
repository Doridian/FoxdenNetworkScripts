:global SYNCUSERNAME
:global SYNCPASSWORD
:global SYNCTARGETS
/ip dns static export file=_dnssync.tmp.rsc;
:delay 2
:local dnsvalues [/file get _dnssync.tmp.rsc contents];
:local dnsstate "/ip dns set allow-remote-requests=no\n:delay 1\n/ip dns static remove [/ip dns static find];\n$dnsvalues\n:delay 1\n/ip dns set allow-remote-requests=yes\n/file remove _dnssync.tmp.auto.rsc";
/file set _dnssync.tmp.rsc contents=$dnsstate;
:delay 2
:foreach SYNCTARGET in=$SYNCTARGETS do={
	/tool fetch address="$SYNCTARGET" mode=ftp upload=yes src-path=_dnssync.tmp.rsc dst-path=_dnssync.tmp.auto.rsc user="$SYNCUSERNAME" password="$SYNCPASSWORD"
}
:delay 1
/file remove _dnssync.tmp.rsc
