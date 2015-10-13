# the solver used here is a concatanation of the caffe solver and caffe arch file
# a separator is added to indicat the seperation of their contents
# this script first seperate the combined file into two files: solver file and arch
# then the solver and arch files will be configured/filled 
scene=20101006
arch=deploy_3layer_stage1.prototxt
basedir=/home/lein/sar_dnn/dataset/beaufort_2010_2011/batches_45
meanfile=${basedir}/mean_std.txt
trainsource=${batchdir}/source.txt
weights=${basedir}/model_stage1/_iter_40000.caffemodel
imagedir=/home/lein/sar_dnn/dataset/beaufort_2010_2011/hhv
featurename=fc5
hh=${scene}-HH-8by8-mat.tif
hv=${scene}-HV-8by8-mat.tif
image=${imagedir}/${hh},${imagedir}/${hv}
predictdir=${basedir}/predict_stage1
mkdir -p ${predictdir}
predict=${predictdir}/${scene}.tif
archfill=.fill_${arch}
cp ${arch} ${archfill}

fancyDelim=$(printf '\001')
sed -i "s${fancyDelim}\$train_mean${fancyDelim}${meanfile}${fancyDelim}g" $archfill
gdb --args ../../caffe/build/tools/caffe_predict_fcnn \
    --model=${archfill} \
    --weights=${weights} \
    --image=${image} \
    --meanfile=${meanfile} \
    --featurename=${featurename} \
    --predict=${predict}

