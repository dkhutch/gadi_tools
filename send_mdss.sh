#!/bin/bash

arcdir=a15_c3_pr
fname=md_${arcdir}

cat << EOF > $fname 
#!/bin/bash
#PBS -P y99
#PBS -q copyq
#PBS -l walltime=10:00:00
#PBS -l ncpus=1
#PBS -l mem=4GB
#PBS -l storage=gdata/hh5+scratch/y99+massdata/y99
#PBS -l wd
#PBS -j oe

mdss -P y99 mkdir -p dkh157/${arcdir}
cd ${arcdir}

for x in output??? restart??? ; do
    tar -cf \${x}.tar \${x}
    mdss -P y99 put \${x}.tar dkh157/${arcdir}
    rval=\$?
    if [ \$rval -eq 0 ]; then
        rm \${x}.tar
    else
        echo \$rval
        exit
    fi
done

EOF

qsub $fname
