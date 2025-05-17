#!/bin/bash

# 检查是否提供了GROMACS路径参数
if [ $# -eq 0 ]; then
    # 如果没有提供参数，使用默认路径
    GMXBIN="/opt/software/gromacs2021-GPU/bin"
    echo "使用默认GROMACS路径: $GMXBIN"
else
    # 使用提供的参数作为GROMACS路径
    GMXBIN="$1"
    echo "使用指定GROMACS路径: $GMXBIN"
fi

# 1. 去掉PBC
echo -e "22\n0" | $GMXBIN/gmx_mpi trjconv -s md_0_1.tpr -f md_0_1.xtc -o md_noPBC.xtc -pbc mol -center -n -ur compact

# 2. 移除相对于参考结构的旋转和平移
echo -e "22\n0" | $GMXBIN/gmx_mpi trjconv -s md_0_1.tpr -f md_noPBC.xtc -o md_fit.xtc -n -fit rot+trans

# 3. 开始模拟(确保同目录下有Ligand_GMX.itp文件)
mpirun -np 16 gmx_MMPBSA -O -i mmpbsa.in -cs md_0_1.tpr -ci index.ndx -cg 1 19 -ct md_fit.xtc -cp topol.top