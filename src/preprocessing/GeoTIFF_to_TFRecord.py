from PIL import Image
import numpy as np
import tensorflow as tf
import os
import re
import json
from osgeo import gdal, osr
import glob

class SEN12MS_toolkit(object):
  def __init__(self, dir_input = ".", file_output = ".", tf = ".", geotransform = {}, dir_output = "."):
    self.dir_input = dir_input
    self.file_output = file_output
    self.tf = tf
    self.geotransform = geotransform
    self.dir_output = dir_output
    if not os.path.exists(self.dir_input):
      raise Exception("The specified base_dir for SEN12MS dataset does not exist")


class SEN12MS_geotiff(object):
  def __init__(self, dir_input, file_output):
    self.dir_input = dir_input
    self.file_output = file_output
    if not os.path.exists(self.dir_input):
      raise Exception("The specified base_dir for SEN12MS dataset does not exist")
  def create_geoparameters(self):
    tif_list = glob.glob(self.dir_input + "/*",recursive=True)
    geojson_geotransform = {}
    rgx_exp = re.compile(pattern = "\.tif$")
    for tif in tif_list:
      ds = gdal.Open(tif)
      gt = ds.GetGeoTransform()
      src_srs = osr.SpatialReference()
      src_srs.ImportFromWkt(ds.GetProjection())
      epsg = src_srs.GetAttrValue("AUTHORITY", 1)
      geo_dict = dict(geotransform = gt, epsg=epsg)
      filename = rgx_exp.sub("", os.path.basename(tif))
      geojson_geotransform[filename] = geo_dict
    return geojson_geotransform
  def create_geoparameters_json(self):
    geoparameters = self.create_geoparameters()
    json_geoparameters = "%s/geoparameters.json" % self.file_output
    with open(json_geoparameters, 'w') as json_file:
      json.dump(my_details, json_file)
  def create_TFRecord(self):
    pass

create_tf.create_geoparameters_json()
create_tf = SEN12MS_geotiff(
  dir_input = "/home/aybarpc01/Github/Geohormiguitas/data/lc_93/",
  file_output = "/home/aybarpc01/Github/Geohormiguitas/data/")

json.dumps(geoparameters, ensure_ascii=False)
json.save(geoparameters,"/home/aybarpc01/Github/Geohormiguitas/data/lc_93/geoparameters.json")
dir_input = "/home/aybarpc01/Github/Geohormiguitas/data/lc_93/*.tif"
tif_list = glob.glob(path,recursive=True)
dasda = SEN12MS_toolkit()



parameters = SEN12MS_geotiff.create_geoparameters(dir_input = tiff_path)
SEN12MS_geotiff()

@classmethod
def tf_to_geotiffs(self, tf, geotransform, dir_output = '.'):
pass
    
