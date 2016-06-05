
# clear known_hosts
ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R "$ADDR" &> /dev/null
