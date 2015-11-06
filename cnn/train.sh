# the solver used here is a concatanation of the caffe solver and caffe arch file
# a separator is added to indicat the seperation of their contents
# this script first seperate the combined file into two files: solver file and arch
# then the solver and arch files will be configured/filled 

solver_arch=solver_3layer_fc.prototxt
basedir=/home/lein/sar_dnn/dataset/beaufort_2010_2011/batches_45
batchdir=${basedir}/batch
meanfile=${basedir}/mean_std.txt
trainsource=${batchdir}/train_source.txt
modeldir=${basedir}/model
mkdir -p $modeldir
trainmean=${meanfile}
testsource=${batchdir}/test_source.txt
testmean=${meanfile}
snapshot=${modeldir}/_iter_22000.solverstate
# 1. split solver_arch file into solver file and arch file
solver=.solver_split.prototxt
arch=.arch_train_val_split.prototxt
lines=$(grep -n "##splitmark##" ${solver_arch} | grep -Eo '^[^:]+')
lines=$((lines - 1))
linestail=$(wc -l < ${solver_arch})
linestail=$((linestail - lines - 1))
head -n $lines ${solver_arch} > ${solver}
tail -n $linestail  ${solver_arch} > ${arch}

# 2. fill solver and arch with the correct setting
fancyDelim=$(printf '\001')
sed -i "s${fancyDelim}\$train_mean${fancyDelim}${trainmean}${fancyDelim}g" $arch
sed -i "s${fancyDelim}\$train_source${fancyDelim}${trainsource}${fancyDelim}g" ${arch}
sed -i "s${fancyDelim}\$test_mean${fancyDelim}${testmean}${fancyDelim}g" ${arch}
sed -i "s${fancyDelim}\$test_source${fancyDelim}${testsource}${fancyDelim}g" ${arch}
sed -i "s${fancyDelim}\$net${fancyDelim}${arch}${fancyDelim}g" ${solver}
sed -i "s${fancyDelim}\$snapshot${fancyDelim}${modeldir}/${fancyDelim}g" ${solver}

# 3. run
gdb --args /home/lein/dev/caffe/build/tools/caffe train \
    --solver=${solver} \
    --snapshot=${snapshot} 2>&1 | tee log.txt
# 4. test
#gdb --args /home/lein/dev/caffe/build/tools/caffe test \
#    --model=${arch} --weights=${modeldir}/_iter_17000.caffemodel 2>&1 | tee log.txt

