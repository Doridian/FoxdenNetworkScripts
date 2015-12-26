/ip dhcp-server lease export file=_dhcpsync.tmp.rsc;
:delay 2
:local dhcpvalues [/file get _dhcpsync.tmp.rsc contents];
:local dhcpstate "/ip dhcp-server disable dhcp-lan\n:delay 1\n/ip dhcp-server lease remove [/ip dhcp-server lease find dynamic=no];\n$dhcpvalues\n:delay 1\n/ip dhcp-server enable dhcp-lan\n/file remove _dhcpsync.tmp.auto.rsc";
/file set _dhcpsync.tmp.rsc contents=$dhcpstate;
:delay 2
/tool fetch address=mtik-bedroom.foxden.network mode=ftp upload=yes src-path=_dhcpsync.tmp.rsc dst-path=_dhcpsync.tmp.auto.rsc user=* password=*
:delay 1
/file remove _dhcpsync.tmp.rsc
