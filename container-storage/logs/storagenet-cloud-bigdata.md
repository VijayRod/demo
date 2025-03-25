## bigdata.analysis.processing

```
Apache Spark (processamento distribuído em memória)
Hadoop MapReduce (batch)
Flink / Storm (real time)
```

## bigdata.analysis.visuals

```
Apache Superset (visualização open-source)
Tableau / Power BI (dashboards empresariais)
Python (Pandas, Matplotlib, Seaborn)
```

## bigdata.machinelearning

```
TensorFlow / PyTorch (redes neurais)
Azure ML / Google Vertex AI / AWS SageMaker
MLlib (Spark Machine Learning Library)
```

## bigdata.storage

```
Data Lakes (Azure Data Lake, AWS S3, Google Cloud Storage)
Data Warehouses (Google BigQuery, Amazon Redshift, Snowflake)
HDFS (Hadoop Distributed File System)
```

## bigdata.storage.format.parquet

```
# parquet.create.duckdb

kubectl run -it --rm aks-ssh --image=debian:stable

apt update -y && apt install -y wget && apt install -y unzip && wget https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip
# https://github.com/duckdb/duckdb/releases/download/v1.2.1/duckdb_cli-linux-amd64.zip
unzip duckdb_cli-linux-amd64.zip
chmod +x duckdb
mv duckdb /usr/local/bin/

duckdb -c "COPY (SELECT 1 AS id, 'Ana' AS name, 30 AS age) TO 'data.parquet' (FORMAT 'parquet');"
ls # data.parquet
```

```
# parquet.create.pyarrow (Apache Arrow) (pyarrow com Python)

kubectl run -it --rm aks-ssh --image=debian:stable

apt update -y && apt install -y python3 python3-pip
echo "alias python='python3'" >> ~/.bashrc
source ~/.bashrc
python3 --version
# pip3 --version

# py virtual environment
# apt may not always have the latest version of the libraries, which is why using a virtual environment or conda is generally recommended.
# apt update -y && apt install -y python3.11-venv
python3 -m venv myenv
source myenv/bin/activate  # On macOS/Linux
pip install pandas pyarrow
python3 -c "import pandas as pd; print(pd.__version__)"
python3 -c "import pyarrow; print(pyarrow.__version__)"

# python.create.pandas
apt update -y && apt install -y python3-pandas
python3 -c "import pandas as pd; print(pd.__version__)" # 1.5.3 # to check pandas installation
# python.pyarrow
tbd apt update -y && apt install -y pipx && apt install python3-pyarrow

tbd
echo -e "id,name,age\n1,Ana,30\n2,Carlos,25" > data.csv
python3 -c "
import pandas as pd
import pyarrow.parquet as pq
df = pd.read_csv('data.csv')
pq.write_table(df.to_parquet(), 'data.parquet')
"

ls # data.parquet
```

```
# parquet.spark-shell (Apache Spark)

kubectl run -it --rm aks-ssh --image=debian:stable

spark-shell <<EOF
import org.apache.spark.sql.SparkSession
val spark = SparkSession.builder.appName("ParquetExample").getOrCreate()
import spark.implicits._

val df = Seq((1, "Ana", 30), (2, "Carlos", 25)).toDF("id", "name", "age")
df.write.parquet("data.parquet")
EOF

ls # data.parquet
```

```
# parquet.inspect

import pandas as pd
# Reading a Parquet file data.parquet
df = pd.read_parquet('data.parquet', engine='pyarrow')  # Or use 'fastparquet' if needed
print(df.head())  # Inspect the first few rows

import pyarrow.parquet as pq
# Open the Parquet file data.parquet and inspect the metadata
parquet_file = pq.ParquetFile('data.parquet')
print(parquet_file.schema)  # Print column names and data types
```

## bigdata.storage.nosql

```
MongoDB / CouchDB (documentos JSON)
Cassandra / HBase (bancos distribuídos e escaláveis)
Elasticsearch (busca de grandes volumes de dados)
```
