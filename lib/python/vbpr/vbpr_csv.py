'''
ものオク用VBPR処理
'''
import os
import argparse
import numpy as np
# import pandas as pd
# import pickle
# import glob
# import matplotlib.pyplot as plt
# from tqdm import tqdm

# pandasで表示される列数を省略なしにする
# pd.set_option('display.max_colwidth', -1)

import sys
sys.path.append("/var/www/yoshida_lib/vbpr/")
# from config import *
from vbpr import VBPR
from utils import *
from data import *

import requests
import json
import csv
import boto3
# import time

### 引数解析(parser) ###
parser = argparse.ArgumentParser()

# VBPRの反復訓練回数 Training AUCのスコアが収束する（変化しなくなる）回数を実験的に決める
# parser.add_argument("--epochs", type=int, default=10, help="training epoches")

# BPR(画像特徴ベクトルなし)を実行
parser.add_argument('--bpr', action='store_true', help="performing bpr")

### basse URL ###
parser.add_argument("--url", default="https://www.mnok.net", help="root url of site.")

args   = parser.parse_args()
# epochs = args.epochs

### 1. JSONデータ読み込み ###
json_url = '%s/system/data/vbpr.json' % args.url
data     = requests.get(json_url, headers={"content-type": "application/json"}).json()
# data = json.loads(input())

bucket_name = data["config"]["bucket_name"]
npz_file    = data["config"]["npz_file"]
tempfile    = data["config"]["tempfile"]
epochs      = data["config"]["epochs"]
limit       = data["config"]["limit"]

# npz_file    = "/var/www/auction/tmp/vbpr/vectors.npz"
# tempfile    = "/var/www/auction/tmp/vbpr/temp.npy"

### 2. スパース行列に変換 ###
print("### スパース行列に変換 ###")
data_coo = coo_matrix(( data["bias"], (data["user_key"], data["product_key"])) ) # スパース行列

# print(data_coo)

### 3. トレーニング ###
# (V)BPRインスタンスの作成
vbpr = VBPR()
if args.bpr:
    csv_file = data["config"]["bpr_csv_file"]
    # csv_file = "/var/www/auction/tmp/vbpr/bpr_result.csv"

    ### BPR ###
    vbpr.fit(data_coo, epochs=epochs, lr=.1, verbose=0)
else:
    csv_file = data["config"]["vbpr_csv_file"]
    # csv_file = "/var/www/auction/tmp/vbpr/vbpr_result.csv"

    ### VBPR ###
    ### 4. 画像ベクトル取得、list結合 ###
    # キャッシュ取得
    if os.path.isfile(npz_file):
        npz = dict(np.load(npz_file))
        # print('load')
    else:
        npz = {}
        # print('NEW!!!')

    # S3バケット初期化
    s3     = boto3.resource('s3', region_name='ap-northeast-1')
    bucket = s3.Bucket('mnok')

    # ベクトルのダウンロード
    vectors = []
    for pr_idx, product_id in enumerate(data["product_idx"]):

        try:
            if product_id in npz:
                print('cache load : %s' % product_id)

                vectors.append(npz[product_id])
            else:
                vecotor_file = 'vectors/vector_%s.npy' % product_id
                print('file load : %s' % vecotor_file)
                bucket.download_file(vecotor_file, tempfile)
                # print('load')
                npy = np.load(tempfile)
                # print('append')

                vectors.append(npy)
                # print('cache')
                npz[product_id] = npy # キャッシュ格納
        except:
            # ベクトルのダウンロードに失敗したときは、とりあえず0埋めのベクトルに
            vectors.append(np.zeros((2048), dtype=float))
            print("vector failed (ZERO ARRAY): %s" % product_id)

    # キャッシュファイル保存(更新)
    np.savez_compressed(npz_file, **npz)

    # start = time.perf_counter()

    # PCAを用いて画像特徴ベクトルの次元削減2048→256
    visual_features = pca_embedding(vectors, n_com=256)
    # visual_features = np.array(vectors)

    vbpr.fit(data_coo, item_content_features=visual_features, epochs=epochs, lr=.005)

    # end = time.perf_counter()
    # print(f"実行時間: {end - start} sec")

### 5. 結果を出力 ###
result = []
result.append(["user_id", "product_id", "score", "rank"])

for us_idx, user_id in enumerate(data["user_idx"]):
    tmp_result = []
    for pr_idx, product_id in enumerate(data["now_product_idx"]): # 現在出品中の商品のみ出力
        score = vbpr.predict(pr_idx, us_idx)
        tmp_result.append([user_id, product_id, score])

    sort_result = sorted(tmp_result, reverse=True, key=lambda x: x[2])[:limit] # スコアトップ取得

    # rank取得
    for i, val in enumerate(sort_result):
        result.append([val[0], val[1], val[2], i + 1])

### CSV書き出し ###
with open(csv_file, "w") as f:
    writer = csv.writer(f, lineterminator='\n')
    writer.writerows(result)
