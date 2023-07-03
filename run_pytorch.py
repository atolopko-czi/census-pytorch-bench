import logging
import sys

import numpy as np
import torch
import tiledb

import cellxgene_census
from cellxgene_census.experimental.ml import experiment_dataloader, ExperimentDataPipe
from cellxgene_census.experimental.ml.pytorch import pytorch_logger
from cellxgene_census.experimental.util._eager_iter import util_logger

from io import StringIO

RANDOM_SEED = 123
np.random.seed(RANDOM_SEED)
torch.manual_seed(RANDOM_SEED)


# For testing only
if __name__ == "__main__":
    pytorch_logger.setLevel(logging.DEBUG)
    util_logger.setLevel(logging.DEBUG)

    import tiledbsoma as soma

    tiledb.stats_enable()
    tiledb.stats_reset()

    (
        census_uri_arg,
        organism_arg,
        measurement_name_arg,
        layer_name_arg,
        obs_value_filter_arg,
        column_names_arg,
        sparse_X_arg,
        torch_batch_size_arg,
        num_workers_arg,
    ) = sys.argv[1:]

    census = cellxgene_census.open_soma(uri=census_uri_arg)

    exp_datapipe = ExperimentDataPipe(
        experiment=census["census_data"]["homo_sapiens"],
        measurement_name=measurement_name_arg,
        X_name=layer_name_arg,
        obs_query=soma.AxisQuery(value_filter=(obs_value_filter_arg or None)),
        var_query=soma.AxisQuery(coords=(slice(1, 9),)),
        obs_column_names=column_names_arg.split(","),
        batch_size=int(torch_batch_size_arg),
        sparse_X=sparse_X_arg.lower() == "sparse",
        #soma_buffer_bytes=2 ** 16,
        use_eager_fetch=True
    )

    # dp_shuffle = exp_datapipe.shuffle(buffer_size=len(exp_datapipe))
    # dp_train, dp_test = dp_shuffle.random_split(weights={"train": 0.7, "test": 0.3}, seed=1234)

    dl = experiment_dataloader(exp_datapipe, num_workers=int(num_workers_arg))

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
    print(f"ids n={len(ids)}, n_uniq={len(set(ids))}, min={min(ids)}, max={max(ids)}")

    import json
    with open("tiledb_stats.json", "w") as f:
        json.dump(tiledb.stats_dump(json=True), f)
    
