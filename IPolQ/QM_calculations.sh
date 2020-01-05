#!/bin/bash
#SBATCH --job-name=belly_simaultions.out
#SBATCH --output=bell_simulations.log
#SBATCH --time=999:00:00
#SBATCH --nodes=1
#SBATCH --exclusive

export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/software/usr/gcc-4.9.2/lib64"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/software/usr/hpcx-v1.2.0-292-gcc-MLNX_OFED_LINUX-2.4-1.0.0-redhat6.6/ompi-mellanox-v1.8/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda-7.5/lib64"
export AMBERHOME="/mnt/lustre_fs/users/mjmcc/apps/amber16"
export AMBERHOME2="/mnt/lustre_fs/users/rnw8253/amber16"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$AMBERHOME/lib"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$AMBERHOME2/lib"

mdgxhome=$AMBERHOME2/bin
tleaphome=$AMBERHOME2/bin
orcaRoot="/mnt/lustre_fs/users/mjmcc/apps/orca"
export PATH="$PATH:$orcaRoot"

num_confs=5
sys=PDI

for CONF in `seq 1 ${num_confs}` ;
do
    sed -e "s/SYSTEM/"${sys}"/g" -e "s/<conformation>/"$CONF"/g" ipolq_orca.in > ${sys}${CONF}_ipolq.in
    mv ${sys}${CONF}_ipolq.in CONF${CONF}/
    cd CONF${CONF}/
    mkdir QM/
    $mdgxhome/mdgx -i ${sys}${CONF}_ipolq.in & > ${sys}${CONF}_ipolq.out &
    cd ../
    let "NJOB+=4"
    if [ ${NJOB} -eq 20 ] ; then
        NJOB=0
        wait
    fi
done
wait
