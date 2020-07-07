#!/bin/bash -ue

DIR=$(cd $(dirname $BASH_SOURCE);pwd)
diff  <(sed 's:D:e:g' $DIR/models/GGM05C.GEO) <($DIR/geo-mean.awk $DIR/models/GGM05C.GEO)
