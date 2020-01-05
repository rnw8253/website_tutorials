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
    mkdir CONF${CONF}/
    cp conformations/${sys}${CONF}.pdb CONF${CONF}
    sed -e "s/YY/"${CONF}"/g" equilibrate.tleap > CONF${CONF}.tleap
    mv CONF${CONF}.tleap CONF${CONF}/
    cd  CONF${CONF}/
    rm leap.log
    $tleaphome/tleap -f CONF$CONF.tleap
    cd ../
    done

echo "Running Minimization of Belly systems"
# run minimization of belly simulations for all conformations
NJOB=0
for CONF in `seq 1 ${num_confs}` ;
do
    cd CONF${CONF}/
    time srun $AMBERHOME/bin/pmemd  -O -i ../../min.in -p ${sys}${CONF}.prmtop -c ${sys}${CONF}.rst7 -ref ${sys}${CONF}.rst7 -r ${sys}${CONF}.min.rst7 -o ${sys}${CONF}.min.log -x ${sys}${CONF}.min.nc &
    cd ../
    let "NJOB+=1"
    if [ ${NJOB} -eq 20 ] ; then
        NJOB=0
        wait
    fi
done

wait

echo "Running Equilibration of Belly systems"
# run minimization of equilibration of belly simulations for all conformations
NJOB=0
for CONF in `seq 1 ${num_confs}` ;
    do
    cd CONF${CONF}/
    time srun $AMBERHOME/bin/pmemd  -O -i ../../equil.in -p ${sys}${CONF}.prmtop -c ${sys}${CONF}.min.rst7 -ref ${sys}${CONF}.min.rst7 -r ${sys}${CONF}.equil.rst7 -o ${sys}${CONF}.equil.log -x ${sys}${CONF}.equil\
.nc &
    cd ../
    let "NJOB+=1"
    if [ ${NJOB} -eq 20 ] ; then
        NJOB=0
        wait
    fi
    done
    wait
