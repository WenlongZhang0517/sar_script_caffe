
basedir=/home/lein/sar_dnn/dataset/beaufort_2010_2011/batches_45
model=${basedir}/model/_iter_
arch=deploy.prototxt
meanfile=${basedir}/mean_std.txt
imagedir=/home/lein/sar_dnn/dataset/beaufort_2010_2011/hhv
hh=20101006-HH-8by8-mat.tif
hv=20101006-HV-8by8-mat.tif
image=${hh},${hv}
gdb --args ../../caffe/build/tools/caffe_predict \
    --image=${image} --model=${arch} --weights=${model} --predict=${predict}
