#!/bin/bash
#SBATCH --nodes=1
#SBATCH --job-name=a.out
#SBATCH --time=12:30:00
#SBATCH --gres=gpu:1
#SBATCH --output=output%j.out
#SBATCH --error=error%j.err


./a.out
