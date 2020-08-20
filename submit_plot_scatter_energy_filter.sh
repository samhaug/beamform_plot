echo "#!/bin/bash" > scatter_energy_filter.sbatch
echo "#SBATCH --job-name=scatter_plot" >> scatter_energy_filter.sbatch
echo "#SBATCH --account=jritsema1" >> scatter_energy_filter.sbatch
echo "#SBATCH --export=ALL " >> scatter_energy_filter.sbatch
echo "#SBATCH --nodes=1" >> scatter_energy_filter.sbatch
echo "#SBATCH --ntasks-per-node=1" >> scatter_energy_filter.sbatch
echo "#SBATCH --cpus-per-task=1" >> scatter_energy_filter.sbatch
echo "#SBATCH --mem=180000m" >> scatter_energy_filter.sbatch
echo "#SBATCH --time=01:30:00 " >> scatter_energy_filter.sbatch
echo "#SBATCH --output=scatter_plot.out" >> scatter_energy_filter.sbatch
echo "#SBATCH --error=scatter_plot.err " >> scatter_energy_filter.sbatch

#Run many instances of vespagram.sh to make slides for a movie

echo "source ~/.bashrc" >> scatter_energy_filter.sbatch
echo "module load gmt" >> scatter_energy_filter.sbatch
echo "ulimit -s unlimited" >> scatter_energy_filter.sbatch

echo "plot_scatter_energy_filter.sh" >> scatter_energy_filter.sbatch

sbatch scatter_energy_filter.sbatch
