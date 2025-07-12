# アイスブレイ君 - インフラ構成

## 概要
このディレクトリには、Slack通知機能を含むアイスブレイ君のAWSインフラ構成が含まれています。

## アーキテクチャ
- **ECS Fargate**: Railsアプリケーションのコンテナ実行環境
- **RDS PostgreSQL**: メインデータベース
- **SQS + Lambda**: Slack通知システム
- **Parameter Store**: Slack設定の安全な管理
- **Application Load Balancer**: 負荷分散とHTTPS終端

## 前提条件
- AWS CLI設定済み
- Terraform >= 1.0
- Dockerイメージがビルド済み

## デプロイ手順

### 1. 設定ファイルの準備
```bash
# terraform.tfvars.exampleをコピー
cp terraform.tfvars.example terraform.tfvars

# 必要な値を設定
vim terraform.tfvars
```

### 2. Slackアプリの準備
1. Slack Workspaceで新しいアプリを作成
2. Incoming Webhookを有効化
3. Webhook URLを取得
4. `terraform.tfvars`に設定

### 3. Terraformの初期化
```bash
terraform init
```

### 4. 構成の確認
```bash
terraform plan
```

### 5. インフラのデプロイ
```bash
terraform apply
```

### 6. アプリケーションのデプロイ
```bash
# Dockerイメージをビルド
docker build -t ice-breakun2:latest .

# ECRにプッシュ（必要に応じて）
# aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-northeast-1.amazonaws.com
# docker tag ice-breakun2:latest <account-id>.dkr.ecr.ap-northeast-1.amazonaws.com/ice-breakun2:latest
# docker push <account-id>.dkr.ecr.ap-northeast-1.amazonaws.com/ice-breakun2:latest
```

## 環境変数設定

### 必須設定
- `database_password`: データベースパスワード
- `slack_webhook_url`: SlackのWebhook URL

### オプション設定
- `slack_channel`: 通知先チャンネル（デフォルト: #general）
- `app_image`: アプリケーションのDockerイメージ

## Slack通知のテスト

### 1. 手動テスト
```bash
# SQSキューにテストメッセージを送信
aws sqs send-message \
  --queue-url $(terraform output -raw sqs_queue_url) \
  --message-body '{
    "type": "assignment",
    "user_name": "テストユーザー",
    "assignment_date": "2024-01-15"
  }'
```

### 2. アプリケーションからのテスト
Railsアプリケーションの割り当て機能を実行して、Slackに通知が送信されることを確認します。

## 監視・ログ

### CloudWatch Logs
```bash
# アプリケーションログを確認
aws logs tail /ecs/ice-breakun2 --follow

# Lambda関数のログを確認
aws logs tail /aws/lambda/ice-breakun2-slack-notifier --follow
```

### CloudWatch Metrics
AWSコンソールのCloudWatchダッシュボードで以下を監視できます：
- ECSタスクの状態
- RDSの接続数・CPU使用率
- Lambda関数の実行回数・エラー率
- SQSキューのメッセージ数

## トラブルシューティング

### Slack通知が送信されない場合
1. Parameter Storeの設定を確認
2. Lambda関数のログを確認
3. SQSキューにメッセージが到達しているか確認
4. Slack Webhook URLが正しいか確認

### データベース接続エラー
1. セキュリティグループの設定を確認
2. RDSインスタンスの状態を確認
3. 環境変数の設定を確認

## リソースの削除
```bash
# 全リソースを削除
terraform destroy

# 確認してから実行
terraform plan -destroy
```

## セキュリティ注意事項
- `terraform.tfvars`には機密情報が含まれるため、Gitにコミットしないこと
- Parameter Storeの値は暗号化されている
- データベースは暗号化されている
- プライベートサブネットでアプリケーションを実行

## 料金について
このインフラ構成の概算月額料金：
- ECS Fargate: 約$15-30
- RDS t3.micro: 約$15-20
- Lambda: 約$1-5
- その他（ALB、SQS、Parameter Store等）: 約$10-15

**合計**: 約$40-70/月（使用量により変動） 