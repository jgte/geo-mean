#!/bin/bash -ue

DIR=$(cd $(dirname $BASH_SOURCE);pwd)
diff -y -W 200 <(sed 's:D:e:g' $DIR/models/GGM05C.GEO) <($DIR/geo-mean.awk $DIR/models/GGM05C.GEO)
