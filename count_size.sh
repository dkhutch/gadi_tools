#!/bin/bash
#PBS -P y99
#PBS -q express
#PBS -l walltime=00:30:00
#PBS -l ncpus=1
#PBS -l mem=100MB
#PBS -l storage=gdata/hh5+scratch/y99+scratch/v45
#PBS -l wd
#PBS -j oe

du -d 1 > dir_sizes_y99.txt
