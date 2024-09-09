#!/bin/bash

# Modules required for the postprocessing:
# - intel compilers
# - hdf5
# - netcdf
# - openmpi
# Ensures the correct environment variables are set for compilation
# Will be system dependent, change as necessary. These are set up for
# use on Oxford servers
#===================================================================
module load Workspace_Home
module load iimpi/2023a
module load netCDF-Fortran/4.6.1-iimpi-2023a
module load HDF5/1.14.0-iimpi-2023a
#===================================================================

set OMP_NUM_THREADS=1
set OMP_STACKSIZE=64M
set I_MPI_PIN_DOMAIN=omp
set I_MPI_OFI_PROVIDER=verbs
set I_MPI_PIN_RESPECT_CPUSET=0
unset I_MPI_PMI_LIBRARY

nctools_dir="../src/FRE-NCtools"
install_dir="${PWD}/../postprocessing"
mosaic_dir="${PWD}/../postprocessing/mosaics"
cd $nctools_dir

# # Run autoreconf
autoreconf -i . || { echo "Autoreconf failed"; exit $?; } 

# Make build directory
if [[ ! -d "build" ]] ; then
    mkdir build
fi
cd build

# # Run configure
../configure --with-mpi=yes --with-netcdf=yes --with-netcdf-fortran=yes --prefix=$install_dir ||\
    { echo "Configure failed"; exit $?; }

# Run make
make || { echo "Error in make"; exit $?; }
make install || { echo "Error in make install"; exit $?; }

# Build C24, C32 and C48 mosaics
if [[ ! -d $mosaic_dir ]] ; then
    mkdir $mosaic_dir
fi
PATH=$PATH:$install_dir/bin

for cn in 24 32 48 ; do
    if [[ ! -d $mosaic_dir/C$cn ]] ; then mkdir $mosaic_dir/C$cn ; fi
    cd $mosaic_dir/C$cn
    make_hgrid_parallel --grid_type gnomonic_ed --nlon $((cn*2)) --grid_name "$mosaic_dir/C$cn/hgrid_C$cn"||\
	{ echo "Error in make_hgrid_parallel"; exit $?; }
    make_solo_mosaic --num_tiles 6 --mosaic_name mosaic_C$cn --dir $mosaic_dir/C$cn --tile_file\
    $(find $mosaic_dir/C$cn/ -name "hgrid_C$cn.tile?.nc" -exec basename {} \; | tr '\n' ',' )||\
	{ echo "Error in make_solo_mosaic"; exit $?; }
done



