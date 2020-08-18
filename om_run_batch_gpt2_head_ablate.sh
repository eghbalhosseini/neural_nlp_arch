#!/bin/bash

#SBATCH --job-name=gpt_ablate
#SBATCH --array=0-83
#SBATCH --time=3-12:00:00
#SBATCH --ntasks=1
#SBATCH --mem=180G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ehoseini@mit.edu

LAYERS=$(seq 0 11)
LAYERS+=("all")
LAYERS+=("None")
i=0
for trained in "" "-untrained" ; do
  for layer in ${LAYERS[@]} ; do
    for n_ablate in 3  ; do
      model_name[$i]="arch/gpt2/head_static/L_$layer/H_$n_ablate$trained"
      echo ${model_name[$i]}
      i=$[$i + 1]
    done
  done
done
echo $i
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
