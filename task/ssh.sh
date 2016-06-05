
if [ ! -f ~/.ssh/id_dsa.pub ]; then
  echo "[warning] required id_dsa.pub file not found!"
  task "Create one" "task/ssh.dsa.sh"
fi

task "Upload public key via FTP" "task/ssh.ftp.sh"
