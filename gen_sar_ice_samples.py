#! /usr/bin/python

import sys
import cPickle
import gzip
import os
import sys
import Image
import numpy as np
import math
import gdal
from gdalconst import *
import caffe



def export_proto(input, target, outpath):
    # construct batchs
    vecstr = caffe.io.arraylist_to_datumvector_str(input, target)
    # write batches
    f = open(outpath, "wb")
    f.write(vecstr)
    f.close()

def patch_img(image, points, window):
    #img is a image matrix
    #samples are the locations to extract patches
    #window is the patchsize, should be a odd number, if not, it will be transfered to a odd number by +1
    # check windows size
    if window%2 == 0:
        print "window has to be uneven. abord"
        return
    rl = int(math.floor(window/2))
    rr = int(rl)

    #select available points:
    #conditions: not masked as 0, in image, not out of boundary
    inputs = []
    target = []
    subpoints = []
    for i,point in zip(range(len(points)), points):
         if point[0] >= rl and point[0] < image.shape[2]-rr and \
            point[1] >= rl and point[1] < image.shape[1]-rr :
            inputs.append(image[:,int(point[1])-rl:int(point[1])+rr+1,
            int(point[0])-rl:int(point[0])+rr+1])
            target.append(int(point[2]))
            subpoints.append(point)
    return inputs, target,subpoints

def run(window, sardir, image_subfixes, imadir, ima_subfix, output_dir):
    import pdb
    pdb.set_trace()
    imalist = os.listdir(imadir)
    for fname in imalist:
        if not fname.endswith(ima_subfix):
            imalist.remove(fname)

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    ima_used_dir = output_dir + '/ima_used'
    if not os.path.exists(ima_used_dir):
        os.makedirs(ima_used_dir)
    batch_dir = output_dir + '/batch'
    if not os.path.exists(batch_dir):
        os.makedirs(batch_dir)

    mean = np.zeros(len(image_subfixes), dtype=np.float64);
    mean_squar = np.zeros(len(image_subfixes), dtype=np.float64);
    n_samples = 0
    for fname in imalist:
        print fname
        day = fname.split(ima_subfix)[0]
        inputs = []
        target = []
        outname = batch_dir + '/' + str(day)+'.batch'
        hhv = []
        for subfix in image_subfixes:
            filein = sardir + "/" +  str(day) + subfix
            dataset = gdal.Open(filein, GA_ReadOnly )
            if dataset is None:
                print 'file does not exist:'
                print fname
                return
            image = dataset.ReadAsArray()
            #image = image.astype(np.float32)/255.0
            hhv.append(image)
        hhv = np.asarray(hhv)
        ima = []
        with open(imadir+"/"+fname) as f:
            for line in f:
                point = map(float,line.split(' '))
                # mutiply ice concentration by 10
                point[2] = point[2] * 10
                ima.append(point)
        inputs, target, subpoints = patch_img(hhv, ima, window)
        assert(len(inputs)==len(target)==len(subpoints))
        np.savetxt(ima_used_dir + '/' + str(day)+'_ima_used.txt', np.asarray(subpoints),fmt='%.2f')
        export_proto(inputs,target, outname)

        n_samples += len(target);
        sub_total = [np.sum(data, axis = (1,2) ) for data in inputs]
        sub_total_squar = [np.sum(data.astype(np.int32)*data.astype(np.int32), axis = (1,2) ) for data in inputs]
        mean += np.sum(np.asarray(sub_total), axis = 0)
        mean_squar += np.sum(np.asarray(sub_total_squar), axis = 0 )
    mean = mean / n_samples / window / window
    std = np.sqrt(mean_squar / n_samples / window / window - mean * mean)
    stats_file = output_dir + '/mean_std.txt'
    f = open(stats_file,'w')
    np.savetxt(stats_file, np.concatenate((mean.reshape((2,1)), std.reshape(2,1)), axis = 1), fmt='%.2f')


if __name__ == '__main__':
    sardir = sys.argv[1]
    image_subfixes = sys.argv[2].split(',')
    imadir = sys.argv[3]
    ima_subfix = sys.argv[4]
    window = int(sys.argv[5])
    output_dir = sys.argv[6]

    run(window, sardir, image_subfixes, imadir, ima_subfix, output_dir)
