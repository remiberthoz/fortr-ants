import numpy as np
from pathlib import Path
from scipy.io import FortranFile
from skimage import io as skio


def main():
    from argparse import ArgumentParser
    parser = ArgumentParser()
    parser.add_argument('tif_path', type=Path)
    parser.add_argument('dat_path', type=Path)
    args = parser.parse_args()

    rgb = skio.imread(args.tif_path, plugin="tifffile").astype(np.int32)
    with FortranFile(args.dat_path, mode='w') as foo:
        foo.write_record(np.array(rgb.shape[0]).astype(np.int32))
        foo.write_record(np.array(rgb.shape[1]).astype(np.int32))
        foo.write_record(np.asarray(rgb).astype(np.int32))


if __name__ == "__main__":
    main()
