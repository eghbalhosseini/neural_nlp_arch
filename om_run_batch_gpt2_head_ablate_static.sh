#!/bin/bash

#SBATCH --job-name=gpt_ablate
#SBATCH --array=0-1%2
#SBATCH --time=12:00:00
#SBATCH --ntasks=1
#SBATCH --mem=120G
#SBATCH --mail-type=ALL
#SBATCH --exclude node017,node018
#SBATCH --mail-user=ehoseini@mit.edu

LAYERS=$(seq 0 11)
LAYERS+=("all")
LAYERS+=("None")
i=0
for trained in "" "-untrained" ; do
  for layer in ${LAYERS[@]} ; do
    for ablate_type in 'head_static' ; do
      for n_ablate in  3 6 9  ; do
        model_name[$i]="arch/gpt2/$ablate_type/L_$layer/H_$n_ablate$trained"
        i=$[$i + 1]
      done
    done
  done
done
echo $i

i=0
for benchmark in Fedorenko2016v3-encoding ; do
#Pereira2018-encoding ; do
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
