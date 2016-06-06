
ssh_eval(){
  hr; echo -e "[EXEC] $1\n"
  ssh "$SSH_USER@$ADDR" $1
  echo
}

ssh_push(){
  echo "[info] copy $PWD/$1 to $2$1 on remote filesystem"
  if [[ -d $1 ]]; then
    scp -r "$1" "$SSH_USER@$ADDR:$2"
  else
    scp "$1" "$SSH_USER@$ADDR:$2"
  fi
  echo
}

task(){
  read -p "$1? [y/n] " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    source $2
  fi
  echo
}

hr(){
  printf '\e[90m%*s\n\n\e[0m' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
}

healthcheck(){
  # echo "testing via ping..."
  # ping -q -c3 "$ADDR" > /dev/null
  #
  # if [ $? -ne 0 ]
  # then
  # 	echo "ping failed at: $ADDR"
  #   exit 1
  # fi

  echo "testing ssh access..."
  ssh -q "$SSH_USER@$ADDR" "exit"

  if [ $? -ne 0 ]
  then
  	echo "ssh failed for user $SSH_USER at: $ADDR"

    if [ $? -eq 255 ]
    then
      ssh "$SSH_USER@$ADDR" "exit"
    fi
    exit 1
  fi

  echo "[info] found host at: $ADDR"
  echo
  hr
  ssh_eval "system resource print"
  hr
}
