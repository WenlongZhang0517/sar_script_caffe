basedir=/home/lein/sar_dnn/dataset/beaufort_2010_2011
sardir=${basedir}/hhv
image_subfixes=-HH-8by8-mat.tif,-HV-8by8-mat.tif

imadir=${basedir}/ima
ima_subfix=_ima.txt

window=45
output_dir=/home/lein/sar_dnn/dataset/beaufort_2010_2011/batches_${window}

cmd=$(echo "./gen_sar_ice_samples.py ${sardir} ${image_subfixes} ${imadir} ${ima_subfix} ${window} ${output_dir}")
echo ${cmd}
$cmd
