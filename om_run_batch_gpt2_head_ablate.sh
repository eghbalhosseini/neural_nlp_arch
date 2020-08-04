#!/bin/bash

#SBATCH --job-name=gpt_ablate
#SBATCH --array=0-27
#SBATCH --time=3-12:00:00
#SBATCH --ntasks=1
#SBATCH --mem=180G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ehoseini@mit.edu

LAYERS=$(seq 0 11)
LAYERS+=("all")
LAYERS+=("None")
i=0
for layer in ${LAYERS[@]} ; do
  for n_ablate in 3 9 ; do
    model_name[$i]="arch/gpt2/head/L_$layer/H_$n_ablate"
    i=$[$i + 1]
  done
done

i=0
for benchmark in Pereira2018-encoding ; do
  for model in ${model_name[@]}  ; do
   model_list[$i]="$model"
   benchmark_list[$i]="$benchmark"
   i=$[$i + 1]
  done
done


echo "My SLURM_ARRAY_TASK_ID: " $SLURM_ARRAY_TASK_ID
echo "Running model ${model_list[$SLURM_ARRAY_TASK_ID]}"
echo "Running benchmark ${benchmark_list[$SLURM_ARRAY_TASK_ID]}"

module add openmind/singularity
export SINGULARITY_CACHEDIR=/om/user/`whoami`/st/
RESULTCACHING_HOME=/om/user/`whoami`/.result_caching
export RESULTCACHING_HOME
XDG_CACHE_HOME=/om/user/`whoami`/st
export XDG_CACHE_HOME

singularity exec -B /om:/om /om/user/`whoami`/simg_images/neural_nlp_fz.simg python ~/neural-nlp/neural_nlp run --model "${model_list[$SLURM_ARRAY_TASK_ID]}" --benchmark "${benchmark_list[$SLURM_ARRAY_TASK_ID]}"

