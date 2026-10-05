#!/bin/bash
###############################################################################
# CSC418 - Lab 3 (non-interactive version, for assistant-run on the EC2 box)
# Performs Graded Tasks 1-6, saving transcripts to ~/lab3-logs/taskN.txt
###############################################################################
set -u

WORKDIR="$HOME/lab3-work"
LOGDIR="$HOME/lab3-logs"
mkdir -p "$WORKDIR" "$LOGDIR"
cd "$WORKDIR"

SUDO=""
if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; fi

run() {
  local log="$1"; local display="$2"; shift 2
  printf '$ %s\n' "$display" >> "$log"
  "$@" >> "$log" 2>&1
  echo >> "$log"
}

echo "=========== Task 1 ==========="
L1="$LOGDIR/task1.txt"; : > "$L1"
run "$L1" "cat /etc/os-release" cat /etc/os-release
run "$L1" "uname -a" uname -a
run "$L1" "whoami" whoami
run "$L1" "hostname" hostname
echo "Task 1 done"

echo "=========== Task 2 ==========="
L2="$LOGDIR/task2.txt"; : > "$L2"
run "$L2" "mkdir -p labwork/data labwork/scripts" mkdir -p labwork/data labwork/scripts
run "$L2" 'echo "Sample dataset for CSC418 Lab 3" > labwork/data/dataset.txt' \
    bash -c 'echo "Sample dataset for CSC418 Lab 3" > labwork/data/dataset.txt'
run "$L2" 'printf setup script > labwork/scripts/setup.sh' \
    bash -c 'printf "#!/bin/bash\necho \"Lab 3 setup complete\"\n" > labwork/scripts/setup.sh'
run "$L2" "ls -R labwork" ls -R labwork
run "$L2" "cat labwork/data/dataset.txt" cat labwork/data/dataset.txt
echo "Task 2 done"

echo "=========== Task 3 ==========="
L3="$LOGDIR/task3.txt"; : > "$L3"
if command -v apt-get >/dev/null 2>&1; then
  run "$L3" "sudo apt-get update" $SUDO apt-get update
  run "$L3" "sudo apt-get install -y tree" $SUDO apt-get install -y tree
  run "$L3" "tree --version   # verify the tool works" tree --version
  run "$L3" "tree labwork     # use it on our structure" tree labwork
  run "$L3" "sudo apt-get remove -y tree   # remove it again" $SUDO apt-get remove -y tree
  run "$L3" 'which tree || echo "tree is no longer installed"' \
      bash -c 'which tree || echo "tree is no longer installed"'
  run "$L3" "dpkg -l tree   # confirm removal" dpkg -l tree
elif command -v dnf >/dev/null 2>&1; then
  run "$L3" "sudo dnf check-update" $SUDO dnf check-update
  run "$L3" "sudo dnf install -y tree" $SUDO dnf install -y tree
  run "$L3" "tree --version   # verify the tool works" tree --version
  run "$L3" "tree labwork     # use it on our structure" tree labwork
  run "$L3" "sudo dnf remove -y tree   # remove it again" $SUDO dnf remove -y tree
  run "$L3" 'which tree || echo "tree is no longer installed"' \
      bash -c 'which tree || echo "tree is no longer installed"'
  run "$L3" "dnf list installed | grep -i tree || echo \"tree not in installed list\"" \
      bash -c 'dnf list installed 2>/dev/null | grep -i tree || echo "tree not in installed list"'
fi
echo "Task 3 done"

echo "=========== Task 4 ==========="
L4="$LOGDIR/task4.txt"; : > "$L4"
run "$L4" "sudo useradd -m labuserA" $SUDO useradd -m labuserA
printf '$ %s\n' "echo 'labuserA:***' | sudo chpasswd   # set password for labuserA" >> "$L4"
echo 'labuserA:TempLab3Pass' | $SUDO chpasswd >> "$L4" 2>&1
echo "(password set)" >> "$L4"; echo >> "$L4"
run "$L4" "sudo useradd -m labuserB" $SUDO useradd -m labuserB
printf '$ %s\n' "echo 'labuserB:***' | sudo chpasswd   # set password for labuserB" >> "$L4"
echo 'labuserB:TempLab3Pass' | $SUDO chpasswd >> "$L4" 2>&1
echo "(password set)" >> "$L4"; echo >> "$L4"
run "$L4" "sudo groupadd labgroup" $SUDO groupadd labgroup
run "$L4" "sudo usermod -aG labgroup labuserA" $SUDO usermod -aG labgroup labuserA
run "$L4" "sudo usermod -aG labgroup labuserB" $SUDO usermod -aG labgroup labuserB
run "$L4" "id labuserA" id labuserA
run "$L4" "id labuserB" id labuserB
run "$L4" "cat /etc/group | grep labgroup" bash -c 'cat /etc/group | grep labgroup'
echo "Task 4 done"

echo "=========== Task 5 ==========="
L5="$LOGDIR/task5.txt"; : > "$L5"
run "$L5" "touch demo_perms.txt" touch demo_perms.txt
run "$L5" "ls -l demo_perms.txt   # default permissions" ls -l demo_perms.txt
run "$L5" "chmod u+x demo_perms.txt   # SYMBOLIC 1: add execute for owner" chmod u+x demo_perms.txt
run "$L5" "ls -l demo_perms.txt" ls -l demo_perms.txt
run "$L5" "chmod g-w demo_perms.txt   # SYMBOLIC 2: remove write for group" chmod g-w demo_perms.txt
run "$L5" "ls -l demo_perms.txt" ls -l demo_perms.txt
run "$L5" "chmod 755 demo_perms.txt   # NUMERIC 1: rwxr-xr-x" chmod 755 demo_perms.txt
run "$L5" "ls -l demo_perms.txt" ls -l demo_perms.txt
run "$L5" "chmod 640 demo_perms.txt   # NUMERIC 2: rw-r-----" chmod 640 demo_perms.txt
run "$L5" "ls -l demo_perms.txt" ls -l demo_perms.txt
echo "Task 5 done"

echo "=========== Task 6 ==========="
L6="$LOGDIR/task6.txt"; : > "$L6"
run "$L6" "mkdir shared_dir" mkdir shared_dir
run "$L6" "sudo chown labuserA shared_dir   # change owner" $SUDO chown labuserA shared_dir
run "$L6" "sudo chgrp labgroup shared_dir   # change group" $SUDO chgrp labgroup shared_dir
run "$L6" "chmod 770 shared_dir   # owner+group: rwx, others: none" chmod 770 shared_dir
run "$L6" "ls -ld shared_dir   # expect drwxrwx--- labuserA labgroup" ls -ld shared_dir
echo "Task 6 done"

echo ""
echo "ALL TASKS DONE. Transcripts in $LOGDIR"
