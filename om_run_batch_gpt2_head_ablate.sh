#!/bin/bash

#SBATCH --job-name=gpt_ablate
#SBATCH --array=0-3
#SBATCH --time=96:00:00
#SBATCH --ntasks=1
#SBATCH --mem=267G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ehoseini@mit.edu


i=0

for benchmark in Pereira2018-encoding ; do
  for model in arch/gpt2/head/L_0 arch/gpt2/head/L_5 arch/gpt2/head/L_8 arch/gpt2/head/L_9  ; do

    model_list[$i]="$model"
    benchmark_list[$i]="$benchmark"
    i=$[$i + 1]
  done
done

#echo ${#model_list[@]}
#exit

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

