# Databricks notebook source
# MAGIC %md
# MAGIC # SoilMoisture

# COMMAND ----------

# MAGIC %md
# MAGIC ## Overview
# MAGIC 
# MAGIC This notebook demonstrates how to open and explore the netCDF file, visualize the data, and to a Delta Tabler.
# MAGIC 
# MAGIC ![Volumetric soil moisture at various soil depths](https://raw.githubusercontent.com/ornldaac/netcdf_open_visualize_csv/master/resources/py-nc-visualize.png)
# MAGIC 
# MAGIC ## Source Data
# MAGIC 
# MAGIC The source data is a netCDF file ([soil_moist_20min_Kendall_AZ_n1400.nc](https://daac.ornl.gov/daacdata/eos_land_val/SoilSCAPE/data//soil_moist_20min_Kendall_AZ_n1400.nc)) consisting of  volumetric root zone soil moisture data from a location in Kendall, Arizona, USA. This data was collected as a part of SoilSCAPE (Soil moisture Sensing Controller and Optimal Estimator) project (https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1339)
# MAGIC 
# MAGIC ## Prerequisites
# MAGIC ### Packages
# MAGIC Python 3 or later. Python modules: netCDF4, numpy, pandas, matplotlib, xarray
# MAGIC ### Data Storage
# MAGIC The source data is stored in a external storage mount attached to the Databricks cluster
# MAGIC 
# MAGIC ## Tutorial
# MAGIC In this tutorial, we will open and explore the netCDF file, visualize the data, and export to a comma-separated file (CSV). 
# MAGIC 
# MAGIC ### 1. Import python modules
# MAGIC First import the required modules:

# COMMAND ----------

# MAGIC %pip install netcdf4 xarray

# COMMAND ----------

# MAGIC %matplotlib inline
# MAGIC 
# MAGIC import pandas as pd 
# MAGIC import numpy as np
# MAGIC import netCDF4 as nc 
# MAGIC import xarray as xr
# MAGIC import matplotlib.pyplot as plt

# COMMAND ----------

# MAGIC %md
# MAGIC ### 2. Read and explore the netCDF file
# MAGIC Read in the netCDF file from the mount into 'in_nc'.

# COMMAND ----------

DATA_DIR = "/dbfs/mnt/raw/SoilSCAPE_1339"

# COMMAND ----------

in_nc = xr.open_dataset(f"{DATA_DIR}/soil_moist_20min_Kendall_AZ_n1400.nc")
in_nc

# COMMAND ----------

# MAGIC %md
# MAGIC ### 2. Create daily average soil moisture plot
# MAGIC To create soil moisture plots aggregated by day, we will first put the data into a *pandas dataframe*, which let you organize data in a meaningful tabular data structure and does time aggregation easily.

# COMMAND ----------

df = in_nc.to_dataframe()
df = df.pivot_table(values=["soil_moisture"], index="time", columns="depth")
df.index = pd.DatetimeIndex(d.index)
df

# COMMAND ----------

# MAGIC %md
# MAGIC Now we will convert the original (~ half-hourly) data to daily using *Pandas's `resample()` function"*. 'D' means daily, 'M' means monthly etc. More aliases are listed [here](http://pandas.pydata.org/pandas-docs/stable/timeseries.html#offset-aliases). Notice that we are using "numpy's nanmean" instead of "mean" to exclude all NaN values. Ignore any run time warning messages. 

# COMMAND ----------

# df_daily = df.groupby(pd.Grouper(freq='D', level='time')).aggregate(np.nanmean)
df_daily = df.resample("D").agg(np.nanmean)

df_daily.head(5)

# COMMAND ----------

# MAGIC %md
# MAGIC We will now create plot of daily time series of soil moisture measured at soil depths (5, 15 and 30cm) using python's matplotlib module:

# COMMAND ----------

ylabel_name = 'Soil Moisture'
series_name = 'Depth'

plt.figure()
df.plot()
plt.legend(title=series_name)
plt.ylabel(ylabel_name)

# COMMAND ----------


