# CrypTothML
CrypTothML is a machine learning-based framework for predicting cryptic binding pockets in proteins by integrating molecular dynamics simulations (MSMD) and physicochemical features. This repository contains the code, data, and instructions to reproduce the results described in our publication.

## Features
- Hotspot detection via MSMD simulations with six probe molecules
- Feature extraction from probe and protein surface information
- Cryptic hotspots detection using a machine learning model (AdaBoost)

## Requirements
Python 3.10 or later  
See `requirements.txt` for package dependencies.

## How to Run
To run CrypTothML, 

- exprporer (https://github.com/keisuke-yanagisawa/exprorer_msmd), 

- cosmdanalyzer (in this repository; https://github.com/jkoseki/CrypToth/tree/main/cosmdanalyzer) 

- and Ada_DTC.ipynb (in this repository, https://github.com/cmotono/CrypTothML/) 

must be installed. 

### 1.	Environment Setup
First, you need to create a CrypTothML directory as below.

**`$ mkdir CrypTothML`**

The following three systems are required to run CrypTothML. These systems are available in each GitHub repository. Install each system in a directory with the name of the system.

**Installation of _exprorer_msmd_**
exprorer_msmd is a system for performing mixed-solvent molecular dynamics (MSMD) simulation using GROMACS automatically.
exprorer_msmd is available in https://github.com/keisuke-yanagisawa/exprorer_msmd


**Installation of _cosmdanalyzer_**
cosmdanalyzer is a system for hotspot detection form output of exprorer_msmd.  
cosmdanalyzer is available in this repository; https://github.com/jkoseki/CrypToth/tree/main/cosmdanalyzer.

**Installation of Jupyter Notebook for machine learning (_Ada_DTC.ipynb_)**
Ada_DTC.ipynb is a Jupyter Notebook file for prediction of cryptic hotspots.  
Ada_DTC.ipynb is available in this repository.

An example of the directory structure is as follows.

![image](https://github.com/user-attachments/assets/65217c06-7f12-40e3-99c8-e1816f32cf50)


### 2.	Execution of CrypTothML
#### 2.1    Detection of hotspots based on MSMD simulation
In CrypTothML, it is necessary to perform MSMD simulation using 6 different probes (benzene, isopropanol, phenol, imidazole, acetonitrile, and ethylene glycol) to detect hotpots which are candidates of cryptic sites (Perform MSMD simulations for each of the six types of probes).


##### 2.1.0    Making working directory
You need to create two working directories in the CrypTothML directory. For convenience, the PDB ID is used for the names of the working directories.

**`$ cd CrypTothML`**

**`$ mkdir 2am9 2am9_WAT`**

In the “2am9” directory, you need to create directories in which the results of MSMD simulation are saved for each probe. 
In the “2am9_WAT” directory, the results of MD simulation in water phase are saved. Here, you create a directory with probe ID name for each probe. Probe IDs are defined as below.

- A00: Benzene
- A01: Isopropanol
- A20: Phenol
- A37: Imidazole
- B71: Acetonitrile
- E20: Ethylene glycol

**`$ cd 2am9`**

**`$ mkdir A00 A01 A20 A37 B71 E20`**

*Also create WAT directory which is the directory for MSMD without probe (in water phase).

##### 2.1.1    Performing MSMD simulation using exprorer_msmd
**Input file preparation**
Store the following three files in each probe directory. 

- PDB file: e.g. 2am9.pdb
The input PDB file should be preprocessed as necessary.

- Probe molecule file: e.g. A20.mol2 and A20.pdb
These files are created by performing structure optimization and partial charge assignment for the probe using Gaussian 16 software package.
For details, please refer to the GitHub repository of _explorer_msmd_ (https://github.com/keisuke-yanagisawa/exprorer_msmd).

- The YAML file defining the protein, probe molecules, and simulation protocol. <br>
For details about this file, please refer to the GitHub repository of _explorer_msmd_ (https://github.com/keisuke-yanagisawa/exprorer_msmd).

The directory structure is as follows.

![image](https://github.com/user-attachments/assets/072bacf0-0984-4d81-9e3d-0d8a817ae032)

Example of YAML files and probe molecule files for CrypTothML are available in This page.

**Running _exprorer_msmd_**
You can execute exprorer_msmd as below.

**`$ cd ../exprorer_msmd`**

**`$ ./exprorer_msmd ../2am9/A20/msmd_protocol_A20.yaml`**

In this step, 20 runs of 40 ns MSMD simulation were executed. After the execution, results are saved into “output” directory in the A20 directory.

Then voxel file in OpenDX format which is necessary to calculation of probe occupancy for hotspot detection is generated based on trajectories of 20 runs of MSMD simulation. The voxel file can be generated using the following command.

**`$ ./protein_hotspot ../ /2am9/A20 /msmd_protocol.yaml`**

maxPMAP_2am9_A20_nVH.dx file is generated in the “output” directory.


**Running exprorer_msmd without probe molecules** 
In CrypTothML, MD simulation in water phase is also necessary. For the MD simulation, protein structure obtained in trajectory at 20 ns of the MSMD simulation ifs used as input PDB file (initial structure). 
20 runs of the MD simulation should be performed for each probe. The input PDB files for the 20 MD simulations is the same file as that for MSMD simulations;  2am9.pdb.

- store the PDB file in WAT directory.

**`$ cd 2am9_WAT`**

YAML file is also necessary. Example of YAML files for the MD simulation (e.g. msmd_protocol_WAT_A20.yaml) is available in this page. It needs to prepare dummy probe files since exprorer_msmd is used for the MD simulation. For convenience, A20.mol2 and A20.pdb are used as dummy probe files. Those files are also stored in WAT directory.

![image](https://github.com/user-attachments/assets/4da39b78-4366-4fcf-aff9-749c105147d0)

execute exprorer_msmd without probe molecules as below.

**`$ ./exprorer_msmd ../2am9_WAT/msmd_protocol_WAT.yaml`**

“2am9_A20_woWAT_10ps.pdb” file is generated in the “system0” directory of the “output” directory of A20_0 directories. This file is necessary for the next step.


##### 2.1.2    Detection of hotspots based on the results of _exprorer_msmd_
_cosmdanalyzer_ can generate hotspot files showing hotspot position and amino acids contacting hotspots based on the maxPMAP_2am9_probe ID_nVH.dx obtained from each MSMD simulations with the probe (probe ID is A00, A01, A20, A37, B71 and E20, respectively). A setting file (setting.toml) is necessary to execute cosmdanalyzer. Example of setting.toml is available in this page. Then the setting.toml file is stored into cosmdanalyzer directory.


**Running cosmdanalyzer** 
You can execute exprorer_msmd as below.

**`$ cd ../cosmdanalyzer`**

**`$ python cosmdanalyzer.py -s setting.toml ../output/ ../2am9/ -v`**

After execution of cosmdanalyzer, spot_probe.toml file and A00, A01, A20, A37, B71 and E20 directories are generated in the “output” directory. 
The correspondence between spots and probes is described in the spot_probe.toml file. In the A00 directory, A00_out.pdb file and spots directory are generated. 
A00_out.pdb is a file that shows the location of the hotspot in the protein structure in final frame of the MSMD simulation with the probe. 
In the spots directory, spot PDB files (spots1.pdb, spots2.pdb, …) show atoms of amino acids contacting to each hotspot. 
The structures of proteins in the final frame of MSMD simulation do not differ greatly among probes, so the A00 spots data is used as input data of DAIS analysis.

#### 2.2    Prediction of hotspots corresponding to cryptic sites
##### 2.2.1    Feature File Preparation
Use provided Perl scripts:

**`$ perl calc_feature.pl spot_probe.toml all_info.txt > output_probe.txt`**

**`$ perl calc_feature_water.pl spot_probe.toml all_info.txt > output_water.txt`**

**`$ perl merge_script.pl`**

Output: feature file "feature_2am9.csv" is generated.

##### 2.2.2    Cryptic Sites Prediction
Run the Jupyter Notebook with the merged feature file (sample_features.csv) as input.　

Output: prediction_output.csv

Columns include:　

- all columns from sample_features.csv　
- predicted_proba: Confidence score. The closer this value is to 1, the higher the probability that the hotspot corresponds to a cryptic site.
We recommend the threshold predicted_proba≥0.5.


## Citation
If you use this code, please cite our paper:

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.




