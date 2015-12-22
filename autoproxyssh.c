#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <netdb.h>
#include <arpa/inet.h>

#define SSH_LOCAL "/usr/bin/ssh"
#define NETCAT_LOCAL "/usr/bin/nc"

#define NETCAT_REMOTE "nc"

// clang/gcc -O3 -mtune=native -march=native -mbmi -mbmi2 autoproxyssh.c -o autoproxyssh

uint32_t gen_mask(const uint_fast8_t msb) {
	const uint32_t src = (uint32_t)1  << msb;
	return (src - 1) ^ src;
}

int usage() {
	printf("autoproxyssh [HOST] [PORT] [SUBNET] [SUBNET BITS] [BOUNCER HOST]\n");
    printf("\nLaunching this program on its own outside of ProxyCommand is not useful\n");
    printf("\nOperation of this tool requires a split-view DNS where your LAN hosts resolve publically using non-LAN IPs (or don't resolve at all). You must not add them to your hosts file!\n");
    printf("Use in your ~/.ssh/config as follows assuming 192.168.2.0/24 is your LAN and jumphost.external.com is a server inside your LAN that you can reach from the internet:\n");
    printf("\tHost myhost.lan\n");
    printf("\t\tProxyCommand /usr/local/bin/autoproxyssh %%h %%p 192.168.2.0 24 jumphost.external.com\n");
	return 1;
}

int main(int argc, char** argv) {
	if (argc < 6) {
		return usage();
	}

	char* host = argv[1];
	char* port = argv[2];

	// All of those are Network Byte Order (reverse)
	uint32_t subnet_ip;
	if(inet_pton(AF_INET, argv[3], &subnet_ip) != 1) {
		return usage();
	}
	uint32_t subnet_mask = gen_mask(atoi(argv[4]) - 1);

    uint32_t host_ip = 0;
    struct hostent* host_ent = gethostbyname(host);
    if (host_ent) {
        host_ip = *(uint32_t*)host_ent->h_addr_list[0];
    }

	if((host_ip & subnet_mask) == subnet_ip) {
		execl(NETCAT_LOCAL, NETCAT_LOCAL, host, port, NULL);
	} else {
		execl(SSH_LOCAL, SSH_LOCAL, argv[5], NETCAT_REMOTE, host, port, NULL);
	}

	return usage();
}
