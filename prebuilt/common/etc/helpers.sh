#!/system/bin/sh
: '
 ============ Copyright (C) 2010 Jared Rummler (JRummy16) ============
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 =====================================================================
'

: ' =========================================================
 function name: sysrw
 parameters: void
 returns: void
 description:
    Mounts system read/write
============================================================= '
sysrw() {
	busybox mount -o remount,rw /system
}

: ' =========================================================
 function name: sysro
 parameters: void
 returns: void
 description:
    Mounts system read-only
============================================================= '
sysro() {
	busybox mount -o remount,ro /system
}

: ' =========================================================
 function name: get_system_reboot
 parameters: void
 returns: void
 description:
    Performs a system reboot
============================================================= '
get_system_reboot() {
	am start -a android.intent.action.REBOOT
}

: ' =========================================================
 function name: get_reboot
 parameters: void
 returns: void
 description:
    Performs a system reboot
============================================================= '
get_reboot() {
	reboot
}

: ' =========================================================
 function name: get_fast_reboot
 parameters: void
 returns: void
 description:
    Restarts the system
============================================================= '
get_fast_reboot() {
	busybox killall system_server
}

: ' =========================================================
 function name: get_shutdown
 parameters: void
 returns: void
 description:
    Shutdown the system
============================================================= '
get_shutdown() {
	reboot -p
}

: ' =========================================================
 function name: get_reboot_recovery
 parameters: void
 returns: void
 description:
    Reboots into recovery
============================================================= '
get_reboot_recovery() {
	reboot recovery
}

: ' =========================================================
 function name: get_system_mount
 parameters: void
 returns: 
	"rw": if system is mounted read/write
	"ro": if system is mounted read-only
 description:
    Returns the current system mount
============================================================= '
get_system_mount() {
	mount | busybox grep /system | busybox awk '{print $4}' | busybox cut -d ',' -f1
}

: ' =========================================================
 function name: is_busybox_installed
 parameters: void
 returns: 0 if busybox is installed, 1 if not installed
 description:
    Checks if busybox is installed
============================================================= '
is_busybox_installed() {
	if ! busybox > /dev/null 2>&1; then
		return 1
	fi
	return 0
}

: ' =========================================================
 function name: is_busybox_applet_available
 parameters: 
	$1: name of the applet
 returns: 0 if applet is available, 1 otherwise
 description:
    Checks if busybox contains a certain applet
============================================================= '
is_busybox_applet_available() {
	applet=$1
	applets=` busybox --list `
	exit_code=$?
	if busybox [ $exit_code -eq 0 ]
	then
		for i in $applets
		do
			if busybox [ $applet == $i ]
			then
				return 0
			fi
		done
	fi
	return 1
}

: ' =========================================================
 function name: 
 parameters: 
	$1: binary name
 returns: 0 if the binary is installed, 1 if not installed
 description:
    Checks if a binary is installed to the system
============================================================= '
is_binary_installed() {
	if busybox [ $# -ne 1 ]; then
		return 1
	fi
	
	binary=$1
	busybox which $binary > /dev/nul 2>&1
	return $?
}

: ' =========================================================
 function name: is_running_as_root
 parameters: void
 returns: 0 if true, 1 if false
 description:
    Checks if the current script is being run as root
============================================================= '
is_running_as_root() {
	if busybox [ $( busybox id -u ) -ne 0 ]; then
		return 1
	fi
	return 0
}

: ' =========================================================
 function name: is_rooted
 parameters: void
 returns: 0 if true, 1 if false
 description:
    Checks if the device has root access
============================================================= '
is_rooted() {
	if ! su -c 'id > /dev/nul 2>&1'; then
		return 1
	fi
	return 0
}

: ' =========================================================
 function name: is_process_running
 parameters: 
	$1: name of the proccess
 returns: 0 if true, 1 if false
 description:
    Checks if a process is currently running
============================================================= '
is_process_running() {
	if busybox [ $# -ne 1 ]; then
		return 1
	fi
	
	process_name=$1
	busybox pidof $process_name > /dev/nul 2>&1
	return $?
}

: ' =========================================================
 function name: is_sd_present
 parameters: void
 returns: 0 if true, 1 if false
 description:
    Checks if the sdcard is mounted
============================================================= '
is_sd_present() {
	if busybox [ -z "$( busybox mount | busybox grep /sdcard )" ]; then
		return 1
	fi
	return 0
}

: ' =========================================================
 function name: open_website
 parameters: 
	$1: the url to open
 returns: void
 description:
    Opens a url with the default browser
============================================================= '
open_website() {
	url=$1
	case $url in
		http*)
			am start ${url}
		;;
		*)
			url="http://${url}"
			am start ${url}
		;;
	esac
}

: ' =========================================================
 function name: view_file
 parameters: 
	$1: path to the file
 returns: void
 description:
    Opens an activity chooser to view a file
============================================================= '
view_file() {
	path=$1
	am start -a android.intent.action.VIEW -t "text/*" -d "file://${path}"
}

: ' =========================================================
 function name: send_email
 parameters: 
	$1: email address
	$2: subject
	$3: email body
 returns: void
 description:
    Opens the default email app to send an email
============================================================= '
send_email() {
	email_address=$1
	subject=$2
	message=$3
	am start -a android.intent.action.SENDTO -d mailto:"${email_address}" \
		--es android.intent.extra.SUBJECT "${subject}" \
		--es android.intent.extra.TEXT "${message}"
}

: ' =========================================================
 function name: get_installed_packages
 parameters: 
	$1: (--filter_system|--filter_data|--filter_sd)
			Filter apps on system, data or sdcard
	$2: (--get_package_path)
			Return the code path instead of the package names
 returns: void
 description:
    Gets a list of installed packages
============================================================= '
get_installed_packages() {
	get_package_path=false
	filter=""

	for i in $@; do
		case $i in
			--filter_system)
				filter="/system/"
			;;
			--filter_data)
				filter="/data/app"
			;;
			--filter_sd)
				filter="/mnt/"
			;;
			--get_package_path)
				get_package_path=true
			;;
		esac
	done

	if $get_package_path
	then
		pm list packages -f \
			| busybox grep "${filter}" \
			| busybox cut -d: -f2 \
			| busybox cut -d= -f1 \
			| busybox sort
	else
		pm list packages -f \
			| busybox grep "${filter}" \
			| busybox cut -d: -f2 \
			| busybox cut -d= -f2 \
			| busybox sort
	fi
}

: ' =========================================================
 function name: installApks
 parameters: 
	$1: "-r" search all sub directories for apks, or...
		path to directory
	$2: path to directory (if recursize)
 returns: void
 description:
    Installs apks to device using package manager
============================================================= '
install_apks() {
	installer_package_name="com.android.vending"
	recursive=false
	case $1 in
		-r|--recursive)
			recursive=true
			shift;
		;;
	esac

	apks_dir=${1:-$EXTERNAL_STORAGE}

	if busybox [ -d $apks_dir ]; then	
		if $recursive
		then
			apks=` busybox find $apks_dir -type f -name *.apk -print `
		else
			apks=` ls $apks_dir/*.apk `
		fi

		for apk in $apks; do
			pm install -i $installer_package_name -r $apk
		done
	fi
}

: ' =========================================================
 function name: set_prop
 parameters: 
	$1: property key
	$2: property value
	$3: path to .prop file to modify
 returns: 0 for success, 1 for failure
 description:
    Set a system property. Reboot may be necessary for
	changes to take affect.
============================================================= '
set_prop() {
	prop_key=$1
	prop_value=$2
	prop_file=${3:-/system/build.prop}
	seperator="="
	exit_status=1

	setprop $prop_key $prop_value

	if busybox [ -e $prop_file ]
	then
		prop_line=` busybox grep -m 1 $prop_key $prop_file `
		if busybox [ -n "${prop_line}" ]
		then
			if busybox [ -n "$( echo $prop_line | busybox grep ' = ' )" ]
			then
				seperator=" = "
			fi
			sysrw
			busybox sed -i "s|${prop_key}${seperator}.*|${prop_key}${seperator}${prop_value}|g" $prop_file
			exit_status=$?
			sysro
		fi
	fi

	return $exit_status
}

: ' =========================================================
 function name: get_runtime
 parameters: 
	$1: start time of the process
	$2: end time of the process
 returns:
	The time it took for the process to complete
	format: HH:mm:ss
 description:
    Gets the runtime for a given process
============================================================= '
get_runtime() {
	starttime=$1
	stoptime=$2
	runtime=` busybox expr $stoptime - $starttime`
	hours=` busybox expr $runtime / 3600`
	remainder=` busybox expr $runtime % 3600`
	mins=` busybox expr $remainder / 60`
	secs=` busybox expr $remainder % 60`
	busybox printf "%02d:%02d:%02d\n" "$hours" "$mins" "$secs"
}

: ' =========================================================
 function name: zipalign_apk
 parameters: 
	$1: path to the apk file
 returns: void
 description:
    zipaligns an apk file if needed
============================================================= '
zipalign_apk() {
	apk=$1
	if busybox [ -e $apk ]; then
		zipalign -c 4 $apk
		exit_status=$?
		case $exit_status in
			0)
				echo "[!] ${apk} is already zipaligned"
			;;
			*)
				if zipalign -f 4 $apk /data/local/pkg.apk
				then
					busybox cp -f /data/local/pkg.apk $apk
					busybox rm -f /data/local/pkg.apk
					echo "[X] Zipaligned ${apk}"
				fi
			;;
		esac
	fi
}

: ' =========================================================
 function name: zipalign_apks
 parameters: void
 returns: void
 description:
    zipaligns all installed apks
============================================================= '
zipalign_apks() {
	if ! is_binary_installed zipalign
	then
		echo "Error: zipalign binary missing."
		return
	fi

	starttime=` busybox date +%s `
	apks=` get_installed_packages --get_package_path `

	echo
	echo "Zipaligning..."
	echo

	sysrw

	for apk in $apks; do
		zipalign_apk $apk
	done

	sysro
	sync

	stoptime=` busybox date +%s `
	runtime=` get_runtime $starttime $stoptime `

	echo
	echo "Zipalign complete! Runtime: ${runtime}"
	echo
}

: ' =========================================================
 function name: set_package_permission
 parameters: 
	$1: package name
	$2: package code path
 returns: void
 description:
    Fixes permission on a package
============================================================= '
set_package_permission() {

	packagename=$1
	apk_path=$2
	packageuid=` busybox grep $apk_path /data/system/packages.xml | busybox sed 's%.*serId="\(.*\)".*%\1%' |  busybox cut -d '"' -f1 `
	data_path=/data/data/$packagename
	
	if busybox [ -e $apk_path ]; then

		echo "Setting permissions for ${packagename} ..."
		appdir=` busybox dirname $apk_path `

		if busybox [ $appdir == /system/app ]; then
			busybox chown 0 $apk_path
			busybox chown :0 $apk_path
			busybox chmod 644 $apk_path
		elif busybox [ $appdir == /data/app ]; then
			busybox chown 1000 $apk_path
			busybox chown :1000 $apk_path
			busybox chmod 644 $apk_path
		elif busybox [ $appdir == /data/app-private ]; then
			busybox chown 1000 $apk_path
			busybox chown :$packageuid $apk_path
			busybox chmod 640 $apk_path
		fi

		if busybox [ -d $data_path ]; then

			busybox chmod 755 $data_path
			busybox chown $packageuid $data_path
			busybox chown :$packageuid $data_path

			dirs=` busybox find $data_path -mindepth 1 -type d `

			for file in $dirs; do

				perm=755
				newuid=$packageuid
				newgid=$packageuid
				fname=` busybox basename $file `

				case $fname in
					lib)
						busybox chmod 755 $file
						newuid=1000
						newgid=1000
						perm=755
					;;
					shared_prefs)
						busybox chmod 771 $file
						perm=660					
					;;
					databases)
						busybox chmod 771 $file
						perm=660
					;;
					cache)
						busybox chmod 771 $file
						perm=600
					;;
					*)
						busybox chmod 771 $file
						perm=771
					;;
				esac

				busybox chown $newuid $file
				busybox chown :$newgid $file

				busybox find $file -type f -maxdepth 1 ! -perm $perm -exec busybox chmod $perm {} ';'
				busybox find $file -type f -maxdepth 1 ! -user $newuid -exec busybox chown $newuid {} ';'
				busybox find $file -type f -maxdepth 1 ! -group $newgid -exec busybox chown :$newgid {} ';'

			done
		fi
	fi
}

: ' =========================================================
 function name: fix_permissions
 parameters: void
 returns: void
 description:
    Fixes permissions for all installed packages
============================================================= '
fix_permissions() {
	starttime=` busybox date +%s `
	packages=` pm list packages -f | busybox cut -d: -f2 `

	echo
	echo "Fixing permissions..."
	echo

	sysrw

	for package in $packages; do
		packagename=` echo $package | busybox cut -d '=' -f2 `
		apk_path=` echo $package | busybox cut -d '=' -f1 `
		set_package_permission $packagename $apk_path	
	done

	sysro
	sync

	stoptime=` busybox date +%s `
	runtime=` get_runtime $starttime $stoptime `
	echo
	echo
	echo "Fix permissions complete! Runtime: ${runtime}"
	echo
}
