#!/bin/bash

# 作業フォルダのフルパス
WorkingDir=/work/ec2_sheduler

# 入力チェックと引数のロード
if [ $# -ne 1 ]; then
    echo "Argument error: Enter only one argument"
    exit 1
else
    command=$1
fi

# 作業フォルダに移動
cd $WorkingDir

# 設定ファイルのロード
. ./config/ec2_connection.txt

# 現在時刻の出力
date +"%Y-%m-%d %T"

# 引数ごとに処理を実行（起動or停止）
if [ $command = "start" ]; then
    # EC2インスタンスの起動実行
    echo "Starting ${ec2_name}..."
    aws ec2 start-instances --instance-ids "${ec2_id}"

    # EC2インスタンスの起動待機/確認
    aws ec2 wait instance-running --instance-ids "${ec2_id}"; echo "Started ${ec2_name}"

elif [ $command = "stop" ]; then
    # EC2インスタンスの停止実行
    echo "Stopping ${ec2_name}..."
    aws ec2 stop-instances --instance-ids "${ec2_id}"

    # EC2インスタンスの停止待機/確認
    while :
    do
        # EC2インスタンス情報の中に'stopped'がある場合、停止していると判断
        stopFlag=`aws ec2 describe-instances --instance-ids "${ec2_id}" | grep stopped | wc -l`
        if [ $stopFlag -eq 1 ]; then
            echo "Stopped ${ec2_name}"
            break
        else
            sleep 5s
        fi
    done

else
    echo "Argument error: invalid argument"
    exit 1
fi