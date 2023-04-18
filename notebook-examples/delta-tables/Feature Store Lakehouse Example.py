# Databricks notebook source
# MAGIC %sql
# MAGIC SHOW TABLES IN samples.nyctaxi

# COMMAND ----------

spark.read.csv("dbfs:/databricks-datasets/nyctaxi/tripdata/yellow/yellow_tripdata_2009-01.csv.gz").head(10)

# COMMAND ----------

# MAGIC %fs
# MAGIC ls /databricks-datasets/nyctaxi/tripdata/yellow/

# COMMAND ----------

from pyspark.sql.functions import col, lit, expr, when
from pyspark.sql.types import *
from datetime import datetime
import time

# COMMAND ----------

schema = nyc_schema = StructType(
    [
        StructField("Vendor", StringType(), True),
        StructField("Pickup_DateTime", TimestampType(), True),
        StructField("Dropoff_DateTime", TimestampType(), True),
        StructField("Passenger_Count", IntegerType(), True),
        StructField("Trip_Distance", DoubleType(), True),
        StructField("Rate_Code", StringType(), True),
        StructField("Store_And_Forward", StringType(), True),
        StructField("Pickup_LocationId", DoubleType(), True),
        StructField("Dropoff_LocationId", DoubleType(), True),
        StructField("Payment_Type", IntegerType(), True),
        StructField("Fare_Amount", DoubleType(), True),
        StructField("Extra", DoubleType(), True),
        StructField("MTA_Tax", DoubleType(), True),
        StructField("Tip_Amount", DoubleType(), True),
        StructField("Tolls_Amount", DoubleType(), True),
        StructField("Improvement_Surcharge", DoubleType(), )
        StructField("Total_Amount", DoubleType(), True),
        StructField("Congestion_Surcharge", DoubleType(), True),
    ]
)

# COMMAND ----------

df = (
    spark.read.format("csv")
    .options(header=True)
    .load(
        "dbfs:/databricks-datasets/nyctaxi/tripdata/yellow/yellow_tripdata_2019-12.csv.gz"
    )
)


# COMMAND ----------

# MAGIC %sql
# MAGIC CREATE CATALOG IF NOT EXISTS nyc_city;
# MAGIC USE CATALOG nyc_city;
# MAGIC CREATE DATABASE IF NOT EXISTS raw_trip;
# MAGIC DROP TABLE IF EXISTS nyc_city.raw_trip.yellow_tripdata;

# COMMAND ----------

df.write.format("delta").saveAsTable("nyc_city.raw_trip.yellow_tripdata");

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * 
# MAGIC FROM nyc_city.raw_trip.yellow_tripdata;

# COMMAND ----------

paymentTypeDF = (
    spark.read.format("csv")
    .options(header=True)
    .options(inferSchema=True)
    .load("dbfs:/databricks-datasets/nyctaxi/taxizone/taxi_payment_type.csv")
    .withColumnRenamed("payment_desc", "payment_description")
)
paymentTypeDF.write.format("delta").saveAsTable("nyc_city.raw_trip.payment_type")

# COMMAND ----------

rawDF = spark.table("nyc_city.raw_trip.yellow_tripdata")

# COMMAND ----------

processedDF = rawDF.withColumn(
    "Year", expr("cast(year(Pickup_DateTime) as int)")
).withColumn("Month", expr("cast(month(Pickup_DateTime) as int)"))



# COMMAND ----------



# COMMAND ----------

processedDF.write.format("delta").mode("append").partitionBy("Year", "Month").saveAsTable(
    "nyc_city.taxidata.cleansed_trip"
)

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT * 
# MAGIC FROM nyc_city.taxidata.cleansed_trip;

# COMMAND ----------

dbutils.fs.head("dbfs:/databricks-datasets/nyctaxi/taxizone/taxi_pay ment_type.csv")
