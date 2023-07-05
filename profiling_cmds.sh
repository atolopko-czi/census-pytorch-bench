set -e

export PYTHONPATH=~/TileDB-SOMA

# quick test
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census --obs-value-filter tissue_general=='tongue' --obs-columns soma_joinid"

# torch batch size
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 128"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 256"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 512"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024"

# soma batch size
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024 --soma-buffer-bytes 134217728"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024 --soma-buffer-bytes 268435456"
python -m profiler -t /usr/bin/time "python run_pytorch.py --census-uri /mnt/scratch/census --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024 --soma-buffer-bytes 536870912"

# sparse
python -m profiler -t /usr/bin/time "python run_pytorch.py --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024 --dense-x"

# tissues (size)
python -m profiler -t /usr/bin/time "python run_pytorch.py --obs-value-filter tissue_general=='lung' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024"
python -m profiler -t /usr/bin/time "python run_pytorch.py --obs-value-filter tissue_general=='blood' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024"
python -m profiler -t /usr/bin/time "python run_pytorch.py --obs-value-filter tissue_general=='brain' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024"

# multiprocessing (worker count)
python -m profiler -t /usr/bin/time "python run_pytorch.py --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024 --num-workers 2"
python -m profiler -t /usr/bin/time "python run_pytorch.py --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024 --num-workers 4"
python -m profiler -t /usr/bin/time "python run_pytorch.py --obs-value-filter tissue_general=='heart' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024 --num-workers 8"

# lazy fetch
python -m profiler -t /usr/bin/time "python run_pytorch.py --obs-value-filter tissue_general=='lung' --obs-columns soma_joinid,dataset_id,cell_type_ontology_term_id --torch-batch-size 1024 --use-lazy-fetch"
