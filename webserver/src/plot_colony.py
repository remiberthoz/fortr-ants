import celluloid as cl
import matplotlib.figure as mpl
import numpy as np
from matplotlib.axes import Axes
from pathlib import Path
from scipy.io import FortranEOFError, FortranFile

from strfdelta import strfdelta


def plot_colony(dat_path, gif_path):

    fig = mpl.Figure()
    ax: Axes = fig.subplots(1)
    camera = cl.Camera(fig)

    print("Opening results file", flush=True)
    with FortranFile(dat_path, mode='r') as foo:
        while 1:

            try:
                _ = foo.read_record('(1,)i4')
            except FortranEOFError:
                break

            t = foo.read_record('(1,)i4')[0]
            clock_ellapsed = foo.read_record('(1,)f4')[0]
            clock_avg_loop = foo.read_record('(1,)f4')[0]
            y = foo.read_record('(1,)i4')[0]
            x = foo.read_record('(1,)i4')[0]
            rgb_map = foo.read_record(f'({y},{x},{3})i4').T
            a = foo.read_record('(1,)i4')[0]
            positions = foo.read_record(f'({a},2)f4').T
            angles = foo.read_record(f'({a},)f4').T
            holds_food = foo.read_record(f'({a},)i4').T
            # n_death_acc = foo.read_record('(1,)i4')[0]
            # n_dupli_acc = foo.read_record('(1,)i4')[0]

            ax.imshow(rgb_map.T)
            ax.scatter(positions[0, np.where(holds_food)], positions[1, np.where(holds_food)], marker='+', color='#fffb5d', alpha=0.5)
            ax.scatter(positions[0, np.where(~holds_food)], positions[1, np.where(~holds_food)], marker='.', color='#ff00e5', alpha=0.5)
            # ax.quiver(positions[0], positions[1], np.cos(angles), np.sin(angles), angles='xy', color='#cccccc', alpha=0.5, pivot='mid')
            stime = f"t: {t}"
            sclock = f"Ellapsed: {strfdelta(clock_ellapsed, fmt='{H:02}h{M:02}m{S:02.0f}s', inputtype='s')} ({clock_avg_loop*1000:.3e}ms/loop)"
            # sstats = f"death: {n_death_acc}, dupli: {n_dupli_acc}"
            ax.text(0.5, 1.01, "\n".join([stime, sclock]), transform=ax.transAxes, ha='center', va='bottom')
            ax.axis('off')
            camera.snap()


    print("Saving GIF", flush=True)
    anim = camera.animate(interval=0.25)
    anim.save(gif_path, writer='ffmpeg')
    print("Done plotting & saving")


def main():
    from argparse import ArgumentParser
    import matplotlib.pyplot as plt
    parser = ArgumentParser()
    parser.add_argument('dat_path', type=Path)
    parser.add_argument('gif_path', type=Path)
    args = parser.parse_args()
    plot_colony(args.dat_path, args.gif_path)
    plt.show()


if __name__ == "__main__":
    main()
