import logging

import cellxgene_census
import click
import numpy as np
import tiledb
import tiledbsoma as soma
import torch
from cellxgene_census.experimental.ml import experiment_dataloader, ExperimentDataPipe
from cellxgene_census.experimental.ml.pytorch import pytorch_logger
from cellxgene_census.experimental.util._eager_iter import util_logger
import os

RANDOM_SEED = 123
np.random.seed(RANDOM_SEED)
torch.manual_seed(RANDOM_SEED)


@click.option("--census-uri", help="URI to census tiledb")
@click.option("--organism", default="homo_sapiens", help="Organism to use")
@click.option("--measurement-name", default="RNA")
@click.option("--layer-name", default="raw", help="Layer name to use")
@click.option("--obs-value-filter", default=None, type=str, help="Obs value filter to use")
@click.option("--obs-columns", default=[])
@click.option("--num-genes", default=None, type=int)
@click.option("--sparse-x/--dense-x", default=False, show_default=True)
@click.option("--torch-batch-size", default=128)
@click.option("--num-workers", default=0)
@click.option("--soma-buffer-bytes", type=int)
@click.option("--use-eager-fetch/--use-lazy-fetch", default=True, show_default=True)
@click.option("--pytorch-debug-gc", is_flag=True)
@click.option("--pytorch-debug-empty-tensors", is_flag=True)
@click.command()
def run_pytorch(census_uri,
                organism,
                measurement_name,
                layer_name,
                obs_value_filter,
                num_genes,
                obs_columns,
                sparse_x,
                torch_batch_size,
                num_workers,
                soma_buffer_bytes,
                use_eager_fetch,
                pytorch_debug_gc,
                pytorch_debug_empty_tensors,
                ) -> None:
    pytorch_logger.setLevel(logging.DEBUG)
    util_logger.setLevel(logging.DEBUG)

    if pytorch_debug_gc:
        print('setting PYTORCH_DEBUG_GC')
        os.environ['PYTORCH_DEBUG_GC'] = 'True'

    if pytorch_debug_empty_tensors:
        print('setting PYTORCH_DEBUG_EMPTY_TENSORS')
        os.environ['PYTORCH_DEBUG_EMPTY_TENSORS'] = 'True'

    tiledb.stats_enable()
    tiledb.stats_reset()

    census = cellxgene_census.open_soma(uri=census_uri)

    exp_datapipe = ExperimentDataPipe(
        experiment=census["census_data"][organism],
        measurement_name=measurement_name,
        X_name=layer_name,
        obs_query=soma.AxisQuery(value_filter=(obs_value_filter or None)),
        var_query=soma.AxisQuery(coords=(slice(0, num_genes),)) if num_genes else soma.AxisQuery(),
        obs_column_names=obs_columns.split(","),
        batch_size=int(torch_batch_size),
        return_sparse_X=sparse_x,
        soma_buffer_bytes=soma_buffer_bytes,
        use_eager_fetch=use_eager_fetch
    )

    # dp_shuffle = exp_datapipe.shuffle(buffer_size=len(exp_datapipe))
    # dp_train, dp_test = dp_shuffle.random_split(weights={"train": 0.7, "test": 0.3}, seed=1234)

    dl = experiment_dataloader(exp_datapipe, num_workers=int(num_workers))

    i = 0
    rows = 0
    datum = None
    ids = []
    for i, datum in enumerate(dl):
        rows += len(datum[1][:, 0])
        ids.extend(datum[1][:, 0].tolist())
        # if (i + 1) % 1000 == 0:
        #     print(f"Received {rows} rows in {i} torch batches, {exp_datapipe.stats()}:\n{datum}")
    print(f"Received {rows} rows in {i} torch batches, {exp_datapipe.stats()}:\n{datum}")
    if len(ids) > 0:
        print(f"ids n={len(ids)}, n_uniq={len(set(ids))}, min={min(ids)}, max={max(ids)}")

    tiledb.stats_disable()
    tiledb_stats = tiledb.stats_dump(version=False, print_out=False, verbose=True)
    
    import json
    with open("tiledb_stats.json", "w") as f:
        json.dump(json.loads(tiledb_stats), f)


if __name__ == '__main__':
    run_pytorch()
