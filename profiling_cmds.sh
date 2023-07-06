set -e

export PYTHONPATH=~/TileDB-SOMA

rm -rf profiling_db

pip list > pip_packages.txt

# quick test
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='tongue' --obs-columns soma_joinid"

# torch batch size
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 128"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 256"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 512"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024"

# soma batch size
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --soma-buffer-bytes 134217728"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --soma-buffer-bytes 268435456"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --soma-buffer-bytes 536870912"

# sparse
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --sparse-x"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='lung' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --sparse-x"

# multiprocessing (worker count)
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --num-workers 2"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --num-workers 4"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --num-workers 8"

# lazy fetch
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='lung' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --use-lazy-fetch"

# tissues (size)
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='lung' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='blood' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter tissue_general=='brain' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id"

# # cell_types (size)
# python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter cell_type=='neuron' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id"
# python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter cell_type=='macrophage' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id"

# # full corpus (primary cells)
# python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census-2023-07-03 --obs-value-filter is_primary_data==True --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id"
