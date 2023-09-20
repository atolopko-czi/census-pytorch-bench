set -e

export PYTHONPATH=~/TileDB-SOMA

rm -rf profiling_db

pip list > pip_packages.txt

for SOMA_BUFFER_BYTES in 16777216 8388608 4194304; do
    python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='brain' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --soma-buffer-bytes $SOMA_BUFFER_BYTES --use-lazy-fetch --pytorch-debug-gc --pytorch-debug-empty-tensors"
    python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='brain' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --soma-buffer-bytes $SOMA_BUFFER_BYTES --use-lazy-fetch --pytorch-debug-gc"
    python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='brain' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --soma-buffer-bytes $SOMA_BUFFER_BYTES --use-lazy-fetch"
done
