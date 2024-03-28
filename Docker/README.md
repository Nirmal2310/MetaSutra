### Instructions for Installing the Docker container of MetaSutra

#### Step 1: Installing the base container that MetaSutra Docker Container will use
```bash
docker build -t base:latest base
```
- Please Note that if you are working behind a proxy, edit lines 10,37 and 39 in the base Dockerfile specifying the proxy address. Also, if you are not working behind a proxy, comment on the same lines in the base Dockerfile.

#### Step 2: Installing the Docker container of MetaSutra
```bash
docker build -t metasutra:latest .
```
- Again, if you are working behind a proxy, you can edit lines 13 and 15 in the Dockerfile; otherwise, comment on the same lines.
- The installation will download some databases required by the tools in the pipeline. So, please ensure you have enough space (~90GB) for the docker root directory. If you want to change the docker root directory, you can follow the instructions provided in this [blog.](https://www.ibm.com/docs/en/z-logdata-analytics/5.1.0?topic=software-relocating-docker-root-directory)
- The installation might take a long time, so try to launch the installation inside a screen.

### Running MetaSutra using Docker container
**Note**
- Run this command from the directory containing the sequencing data.
- Ensure the Host Genome Fasta file is in the same directory with the sequencing data.
```bash
docker run -v $PWD:$PWD --name metasutra --cpus 16 --memory 200g --workdir $PWD --rm metasutra:latest bash /module/main.sh -s SRR12345 -r Homo_sapiens_new_reference.fasta -t 16 -m 200
```
You can also loop over this command to run MetaSutra for multiple samples
```bash
while read sample
do
docker run -v $PWD:$PWD --name metasutra --cpus 16 --memory 200g --workdir $PWD --rm metasutra:latest bash /module/main.sh -s $sample -r Homo_sapiens_new_reference.fasta -t 16 -m 200
done < "list"
```
Here, the the list contains the SRA IDs of all the samples in the current working directory.

If you want to calculate run metrics like Run Time, CPU utilization and Peak Memory usage, you can use the **metasutra_run.sh script** given in this directory. Just copy this script to the directory containing the sequencing data. Now you can run the script using the following command:
```bash
bash metasutra_run.sh -s SRR123456 -r Homo_sapiens_new_reference.fasta -t 16 -m 200
```
Again, you can loop over this command to run MetaSutra for multiple samples
```bash
while read sample
do
bash metasutra_run.sh -s $sample -r Homo_sapiens_new_reference.fasta -t 16 -m 200
done < "list"
```
