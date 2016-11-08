# Zcashbenchmark
## A simple script to run zcash benchmark on linux
## Introduction
The script will run `zcash-cli zcbenchmark solveequihash 20` to run 20 benchmark tests (takes ~20 minutes),
Then calculate the average time of those results (total time / 20) to get your 'solve equihash' time.

The output this something like this:
```shel
============== ZCASH BENCHMARK RESULT =================================

============== SYSTEM INFO =============================================

  Distro info:	    Ubuntu 16.04.1 LTS
  Processor:        Core(TM) i7-3520M CPU @ 2.90GHz
  Number of cores:  4
  Speed:            2.90GHz
  Architecture:     x86_64
  Total Memory:     7684Mb
  Total Swap:       7719Mb

=======================================================================

  RESULT: 78.0552

=======================================================================
```
## Usage
Just down loadd run the script, no require sudo
```
./zcashbenchmark.sh
```




