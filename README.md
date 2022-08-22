<div align="center">

# FortrAnts

**An ant trail simulation, written in Fortran.**

This project started as a way to enhance and practice my Fortran skills.<br>
It is not the best ant trail simulation out there, nor the most optimal Fortran code, but it is mine.

![](https://img.shields.io/badge/programmed%20in-fortran-6B2002?style=for-the-badge&logo=fortran&labelColor=A7BFC1)
![](https://img.shields.io/badge/runs%20in-Docker-2496ED?style=for-the-badge&logo=docker&labelColor=A7BFC1)

</div>

---

<div align="center">
<img alt="Demo" height="410" src="https://user-images.githubusercontent.com/1943662/186022520-f3b38424-781e-41b7-931b-8b696a672faf.gif">
</div>


This simulates ants walking in a 2D world. Ants are looking around to **bring back food to their home**. They communicate with each other by leaving **pheromone trails** along their path. The logic of an ant brain is simple:

- While looking for food, follow red pheromones and drop blue pheromones.
- To bring food home, follow blue pheromones and drop red pheromones.

To follow pheromones, each ant can sense a 4x4 pixels area around itself, but this sensing is slightly noisy. The quantity of pheromones dropped decreased after each step, and ants which stumble upon more pheromones that what they would drop, do not drop any. Ants cannot turn around instantly, they are restrained in their movement by a maximum steering angle.

---



<div align="center">

*This repository contains, in addition, a companion webserver to display results in the browser while the simulation is running.*

</div>



## Program input and output

The program reads a [*Fortran unformatted*](https://gcc.gnu.org/onlinedocs/gfortran/File-format-of-unformatted-sequential-files.html) data file to generate the world map, and a simple text file (named *request file*) to configure the output; the output of the program is a GIF file. Companion python scripts can be used to **convert a world map TIFF file into the correct *Fortran unformatted* file format**: see the [*Companion programs*](#companion-scripts) section below. Paths to the location of these three files (world input, request, GIF output) must be provided at the command line when starting the program.


<details><summary>Click to see <b>input and output details</b></summary>

### Input world map

The world map input file should contain the following entries, in this order:

| Type               | Name  | Meaning
|--------------------|-------|---------
| `integer`          | `Y`   | Size of the world map along Y coordinate
| `integer`          | `X`   | Size of the world map along X coordinate
| `integer(3, X, Y)` | `rgb` | A 2D array of RGB values describing the initial composition of the world map.

`integer` variables are coded on 32 bits (4 bytes); arrays are stored in Fortran order. Valid RGB values in the last entry are:

| Hex code     | Meaning
|--------------|---------
| `56, B9, 00` | Wall (ants cannot cross this pixel)
| `FF, FB, 5D` | Home (starting point of ants, and destination when they hold food)
| `5D, 61, FF` | Lake (ants walking in this pixel die) *not implemented, will be interpreted as a wall*

### Request (parameters for output)

The output parameters are two integers and one boolean. The two integers are used to determine which frames to record to generate the GIF. The boolean determines whether or not to pause the simulation after the GIF is generated. The content of this file can be modified during runtime, to alter output parameters.

The first integer corresponds to the record duration, from start to end, in simulation time. The second integer corresponds to the number of frames actually recorded. Inputting `1000` and `100` will record `100` frames, each spaced by `1000/100 = 10` frames, corresponding to a total duration of `1000` frames.

The request file is a text file, in which integers and the boolean must be stored. Integers are simply coded with their values in digits (i.e. `1234`), and the boolean must be stored as either `T` (true) or `F` (false). Values must be separated by one space. A valid request file content is: `1000 10 F`.

### Output GIF file

*TODO*

---
</details>



## Usage

Written specifically in GNU Fortran, the source files located in `simulation/src/` should compile with `gfortran` and no external libraries. Source files must be compiled in the correct order to satisfy dependencies, and then linked. **A Makefile and a Docker environment are available to execute the process in few commands and no headache.**

<details><summary>Click to see <b>Makefile instructions</b></summary><br>

If [`gfortran`](https://gcc.gnu.org/wiki/GFortran) is ready on your machine, running `make all` from within the `simulation/` directory should produce the binary: `simulation/.build/build_latest`. This binary is executable, and requires two arguments on the command line:

- A path to the world map input file
- A path to the output file (which will be appended, not overwritten)
- A path to the request file used to set output parameters

In brief, assuming that `../assets/world.dat` and `/tmp/results/` exist (`request.txt` can be created later):

    cd simulation
    make all
    .build/build_latest ../assets/world.dat /tmp/results/results.dat /tmp/request/request.txt

---
</details>


<details><summary>Click to see <b>Docker instructions</b> (recommended)</summary><br>

If [Docker](https://www.docker.com/get-started/) and [docker-compose](https://docs.docker.com/compose/) are ready on your machine, then running `docker-compose up simu` from the root of the repository should set up containers to build and to run the simulation. As is, the Docker container expects a world map input file located at `assets/world.dat` and a parameter file at `request.txt` for output configuration. The result GIF dumps in a Docker volume.

---
</details>


**As is, the program does not output results.** Instead, it keeps running and running. For the program to dump results in the output file, you have to set output parameters in the request file, and send a POSIX `SIGUSR1` signal to the process.

<details><summary>Click to see how to <b>send the signal on your linux machine</b></summary><br>

1. Find the Process Identifier (PID) of the running simulation program
    - Run the command `ps aux | grep build_latest`
    - Extract the first (integer) number, which should be on the second field, *i.e.* `27276`
2. Send the signal with `kill -s SIGUSR1 27276`

---
</details>

<details><summary>Click to see how to <b>send the signal in a Docker container</b></summary><br>

`docker-compose kill -s SIGUSR1 simu`

---
</details>

<details><summary>Click to see how to <b>use Docker and the companion webserver to send the signal</b> (recommended)</summary><br>

1. `docker-compose up webserver`
2. Navigate your web browser to the Docker container's IP address, which appears in the terminal log (likely [`http://127.17.0.2:5000`](http://127.17.0.2:5000))
3. Set parameters for the output in the web form
4. Click the `Generate` blue button on the web page

---
</details>



## Companion programs

### Input data conversion (from TIFF) ![](https://img.shields.io/badge/PROGRAMMED%20IN-PYTHON-F7D14A?style=flat-square&logo=python&labelColor=A7BFC1) ![](https://img.shields.io/badge/RUNS%20IN-CONDA-44A833?style=flat-square&logo=anaconda&labelColor=A7BFC1)

To generate an input data file (as specified in the section [*Program input and output*](#program-input-and-output) above), you may start from a TIFF image file and use the `python` script located in `helpers/tif_to_dat.py`.

<details><summary>See <b>instructions</b></summary><br>

This script runs with dependencies defined in `environment.yml`. If [`conda`](https://docs.conda.io/projects/conda/en/latest/user-guide/getting-started.html) and [`python`](https://www.python.org/about/gettingstarted/) are ready on your system, then the following commands should produce a valid input file for the simulation:

```
conda env create -f environment.yml -p ./.env
conda activate ./.env
python helpers/tif_to_dat.py assets/world.tif assets/world.dat
```

command line arguments for the script are:

- a path to a TIFF file, containing RGB pixels coloured as defined in the section [*Program input and output*](#program-input-and-output) above
- a path for the output *Fortran unformatted* file, which will serve as input for the simulation program

---
</details>

### Webserver

The webserver, which can be started according to the procedure described in the subsection [Usage/use-Docker-and-the-companion-webserver...](#usage), will automatically generate and display a GIF after setting the request file and sending the POSIX signal.
