# アイスブレイ君

チームのアイスブレイクスピーチ当番管理システムです。

## 機能

- チームメンバーの管理
- 当番の自動割り当て
- Slack通知機能

## セットアップ

### 1. 依存関係のインストール

```bash
bundle install
```

### 2. データベースの設定

```bash
rails db:create
rails db:migrate
rails db:seed
```

### 3. Slack通知の設定

Slack通知を有効にするには、以下のいずれかの方法で設定してください。

#### 方法1: 環境変数を使用

```bash
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
export SLACK_CHANNEL_ID="C095GP97S90"
```

#### 方法2: Rails credentialsを使用

```bash
rails credentials:edit
```

以下の形式で設定を追加してください：

```yaml
slack:
  webhook_url: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
  channel_id: C095GP97S90
```

### 4. Slack Webhook URLの取得方法

1. Slack ワークスペースにアクセス
2. 「アプリを追加」→「Incoming Webhooks」を検索
3. 「Slackに追加」をクリック
4. 通知を送信したいチャンネルを選択
5. 生成されたWebhook URLをコピー

## 使用方法

### サーバー起動

```bash
rails server
```

### 当番割り当て

1. `/assignments` にアクセス
2. 「今日の当番を割り当て」ボタンをクリック → 単発の当番割り当て + Slack通知
3. 「今週を割り当て」ボタンをクリック → 週の当番割り当て + Slack通知

### Slack通知の内容

- **単発割り当て**: 当番者の名前、日付、Slack IDなどを通知
- **週割り当て**: 今週の当番表を一覧で通知

## 開発

### テスト実行

```bash
bundle exec rspec
```

### 静的解析

```bash
bundle exec rubocop
bundle exec brakeman
```
