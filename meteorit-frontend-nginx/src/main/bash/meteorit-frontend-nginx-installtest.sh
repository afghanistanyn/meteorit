#/bin/bash

#  Copyright 2013 Daniel Giribet <dani - calidos.cat>
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

SHUNIT2_=/usr/share/shunit2/shunit2
NGINX_=${nginx.installfolder_}/sbin/nginx

[ ! -e "$SHUNIT2_" ] && exit 1

yum list installed ${project.artifactId} -q &>/dev/null 
[ -z $? ] && exit 1

host_='localhost'
port_='80'

while getopts "h:u:" flag; do
	case $flag in
		h) host_="$OPTARG";;
		u) url_="$OPTARG";;
	    \?) echo "Invalid option: -$OPTARG" >&2;;
	esac
done
shift $((OPTIND-1))

[ -z "$url_" ] && url_="http://$host_:$port_/"

testNginx() {

	assertTrue 'Nginx is not installed' "[ -e $NGINX_ ]"
	
	wget -q -O - "$url_" | grep 'Welcome to nginx!' -q
	assertEquals "Nginx is not answering ($url_)" 0 $?

}

testNginxRedis() {

	r_="$RANDOM"
	url2_="$url_/test?e=$r_"
	answer_=`wget -q -O - "$url2_"`
	assertEquals "Nginx does not answer to the test URL ($url2_)" 0 $?
	assertEquals "redis value isn't returned correctly" "$r_" "$answer_"
	
}


. $SHUNIT2_
