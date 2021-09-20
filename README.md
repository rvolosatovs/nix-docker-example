# Build docker images with Nix

```sh
$ nix build '.#golangWithPython'
$ docker load < result
b61571a594e1: Loading layer [==================================================>]  1.337GB/1.337GB
Loaded image: golang-with-python:latest
$ docker run --rm -it golang-with-python go version
go version go1.17.1 linux/amd64
$ docker run --rm -it golang-with-python python    
Python 2.7.18 (default, Apr 19 2020, 21:45:35) 
[GCC 10.3.0] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import numpy as np
>>> np.array([2, 3, 4])
array([2, 3, 4])
```
