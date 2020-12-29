#
## about:SystemD aliases
#

if ! command -v fzf > /dev/null ; then
  echo "[bash-config: systemd] fzf is not installed"
  return 0
fi

##Not currently enable
  # link
  # revert
  # add-wants
  # add-requires

systemd_svc_opts="
cat
disable
edit
enable
force-reload
is-active
is-enabled
is-failed
list-dependencies
mask
reenable
reload
reload-or-restart
restart
show
start
status
stop
try-reload-or-restart
try-restart
unmask
"

systemd_cmd_opts="
cancel
condreload
condrestart
condstop
daemon-reexec
daemon-reload
default
emergency
exit
get-default
halt
help
hibernate
hybrid-sleep
import-environment
isolate
is-system-running
kexec
kill
list-jobs
list-machines
list-sockets
list-timers
list-unit-files
list-units
log-level
log-target
poweroff
preset
preset-all
reboot
rescue
reset-failed
revert
service
service-watchdogs
set-default
set-environment
set-property
show-environment
suspend
suspend-then-hibernate
switch-root
unset-environment"

_list_cmd_opts_sc () {
  local cur selctd_svc selctd_svc_opt
  cur=${COMP_WORDS[COMP_CWORD]}
  case $COMP_CWORD in
    1) # Gets list of systemctl commands from $systemd_cmd_opts
      COMPREPLY=($(compgen -W "$(echo "$systemd_cmd_opts")" "$cur"))
      ;;
    2) 
      if [[ "${COMP_WORDS[1]}" == "service" ]] ; then
        if [[ ! "${COMP_WORDS[2]}" ]] ; then
          selctd_svc=$({ systemctl --system list-unit-files --type=service --no-legend | awk '{print $0 "\t" "system"}' ;
           systemctl --user list-unit-files --type=service --no-legend | awk '{print $0 "\t" "user"}' ; } \
           | fzf -e --reverse --tiebreak=index)
        elif [[ "${COMP_WORDS[2]}" ]] ; then
          selctd_svc=$({ systemctl --system list-unit-files --type=service --no-legend | awk '{print $0 "\t" "system"}' ;
           systemctl --user list-unit-files --type=service --no-legend | awk '{print $0 "\t" "user"}' ; } \
           | fzf -q "${COMP_WORDS[2]}" -e --reverse --tiebreak=index)
        fi
        selctd_svc=$(echo $selctd_svc | awk '{print $1 , $NF}')
        selctd_svc_opt=$(echo "$systemd_svc_opts" | fzf -e --reverse --tiebreak=index)
      fi
      COMPREPLY="$selctd_svc $selctd_svc_opt"
      ;;
    4)
      if [[ "${COMP_WORDS[1]}" == "service" ]] ; then
        if [[ ! "${COMP_WORDS[4]}" ]] ; then
          selctd_svc_opt=$(echo "$systemd_svc_opts" | fzf -e --reverse --tiebreak=index)
        elif [[ "${COMP_WORDS[4]}" ]] ; then
          selctd_svc_opt=$(echo "$systemd_svc_opts" | fzf -q "${COMP_WORDS[4]}" -e --reverse --tiebreak=index)
        fi
        COMPREPLY="$selctd_svc_opt"
      fi
      ;;
    esac
}

# help:sc:Systemd fzf wrapper
sc ()
{
  local cmd usage elevated_cmds
  usage="Usage: sc [cmd {user}|service [unit] [system|user] [unit command] {now}]
examples:
\tsc service cupsd.service system restart
\tsc service mpd.service user restart
\tsc service mpd.service enable now user
\tsc daemon-reload
\tsc daemon-reload --user
"

  elevated_cmds='(start|stop|restart|enable|disable|reenable|try-restart|reload|force-reload|try-reload-or-restart|try-restart|mask|unmask)'

  case $1 in
    service)
      case $3 in
        user) cmd="systemctl --user" ;;
        system)
          if [[ $(id -u) -ne 0 ]] ; then
            if [[ $4 =~ $elevated_cmds ]] ; then
              cmd="sudo systemctl"
            else
              cmd="systemctl"
            fi
          else
            cmd="systemctl"
          fi
          ;;
      esac

      if [[ "$5" == "now" ]] ; then
        cmd_arg="--now"
      fi

      if [[ "$4"  == "status" ]] ; then
        $cmd $4 $cmd_arg $2 --no-pager
      else
        $cmd $4 $cmd_arg $2
      fi

      if [[ $4 =~ $elevated_cmds ]] ; then
        echo getting status
        sleep .5
        $cmd status $2 --no-pager
      fi
      ;;
    -h)
      echo -e "$usage"
      ;;
    *)
      systemctl $*
      ;;
  esac
}

complete -F _list_cmd_opts_sc -o default -o bashdefault sc
