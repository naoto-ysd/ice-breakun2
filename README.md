# アイスブレイ君 - Ice Break App

アイスブレイクアプリは、チームメンバーの朝のアイスブレイク当番を自動で管理するRailsアプリケーションです。

## 概要

- **メンバー管理**: チームメンバーの登録・管理
- **当番管理**: 朝のアイスブレイク当番の自動割り当て
- **休暇管理**: 休暇期間の設定により当番対象外の管理
- **Slack連携**: Slack通知による当番のお知らせ（予定）

## 主な機能

### ユーザー管理
- メンバーの登録・編集・削除
- 休暇期間の設定
- Slack IDの管理

### 当番管理
- 自動割り当て機能（当番回数の少ないメンバーを優先）
- 手動割り当て機能
- 3日間の当番表示（今日・明日・明後日）
- 当番の完了・キャンセル機能
- 担当者の変更機能

### 当番割り当てロジック
- 当番回数が最も少ないメンバーを自動選択
- 休暇中のメンバーは自動的に除外
- 同じ日に複数の当番割り当て不可

## 技術スタック

- **言語**: Ruby 3.2.5
- **フレームワーク**: Ruby on Rails 8.0.2
- **データベース**: 
  - 開発環境: PostgreSQL 15
  - テスト環境: SQLite3
- **フロントエンド**: Bootstrap 5, Stimulus, Turbo
- **テスト**: RSpec, FactoryBot
- **コード品質**: RuboCop, Brakeman
- **コンテナ**: Docker, Docker Compose

## 開発環境のセットアップ

### 前提条件

- Docker Desktop がインストールされていること
- Git がインストールされていること

### 1. プロジェクトのクローン

```bash
git clone <repository-url>
cd ice-breakun2
```

### 2. 初回セットアップ

```bash
# 依存関係のインストール
docker-compose run --rm web bundle install

# Dockerイメージのビルド
docker-compose build

# データベースの作成
docker-compose run --rm web rails db:create

# マイグレーションの実行
docker-compose run --rm web rails db:migrate

# シードデータの投入
docker-compose run --rm web rails db:seed
```

### 3. アプリケーションの起動

```bash
# アプリケーションの起動
docker-compose up

# バックグラウンドで起動
docker-compose up -d
```

アプリケーションが起動したら、ブラウザで `http://localhost:3000` にアクセスしてください。

### 4. アプリケーションの停止

```bash
# アプリケーションの停止
docker-compose down

# ボリュームも削除して完全にクリーンアップ
docker-compose down -v
```

## 開発時によく使用するコマンド

```bash
# Rails コンソール
docker-compose run --rm web rails console

# テストの実行
docker-compose run --rm web bundle exec rspec

# RuboCopの実行
docker-compose run --rm web bundle exec rubocop

# Brakemanの実行
docker-compose run --rm web bundle exec brakeman

# マイグレーションの実行
docker-compose run --rm web rails db:migrate

# シードデータの投入
docker-compose run --rm web rails db:seed

# データベースのリセット
docker-compose run --rm web rails db:reset

# webコンテナ内でbashを実行
docker-compose run --rm web bash

# PostgreSQLクライアントでデータベースにアクセス
docker-compose exec db psql -U postgres ice_breakun2_development

# ログの確認
docker-compose logs

# 特定のサービスのログを確認
docker-compose logs web

# リアルタイムでログを確認
docker-compose logs -f web
```

## 開発フロー

1. `docker-compose up` でサービスを起動
2. コードを編集（変更は自動的にコンテナに反映）
3. ブラウザで `http://localhost:3000` にアクセスして確認
4. 必要に応じて `docker-compose run --rm web rails db:migrate` でマイグレーション実行
5. `docker-compose run --rm web bundle exec rspec` でテストを実行
6. `docker-compose run --rm web bundle exec rubocop` でコードの静的解析を実行
7. 開発が完了したら `docker-compose down` で停止

## サービス構成

### webサービス
- **ポート**: 3000
- **役割**: Rails アプリケーション
- **環境**: development
- **ボリューム**: 
  - ソースコード: `.:/rails`
  - Gem: `bundle_data:/usr/local/bundle`
  - Node modules: `node_modules:/rails/node_modules`

### dbサービス
- **ポート**: 5432
- **データベース**: PostgreSQL 15
- **認証情報**:
  - データベース名: `ice_breakun2_development`
  - ユーザー名: `postgres`
  - パスワード: `password`
- **ボリューム**: `postgres_data:/var/lib/postgresql/data`

## トラブルシューティング

### ポート競合エラー

既にポート3000や5432が使用されている場合：

```bash
# 使用中のポートを確認
lsof -i :3000
lsof -i :5432

# docker-compose.ymlでポート番号を変更
ports:
  - "3001:3000"  # 例：ポート3001を使用
```

### データベース接続エラー

```bash
# データベースサービスの状態確認
docker-compose ps

# データベースサービスの起動
docker-compose up db

# データベースの再作成
docker-compose run --rm web rails db:reset
```

### 依存関係のエラー

```bash
# bundleの再インストール
docker-compose run --rm web bundle install

# イメージの再ビルド
docker-compose build --no-cache web
```

### 完全なクリーンアップ

```bash
# ボリュームを含む完全なクリーンアップ
docker-compose down -v

# 再セットアップ
docker-compose run --rm web bundle install
docker-compose build
docker-compose run --rm web rails db:create
docker-compose run --rm web rails db:migrate
docker-compose run --rm web rails db:seed
```

## テスト

```bash
# 全テストの実行
docker-compose run --rm web bundle exec rspec

# 特定のテストファイルの実行
docker-compose run --rm web bundle exec rspec spec/models/user_spec.rb

# 特定のテストの実行
docker-compose run --rm web bundle exec rspec spec/models/user_spec.rb:10
```

## コード品質

```bash
# RuboCopの実行
docker-compose run --rm web bundle exec rubocop

# Brakemanの実行
docker-compose run --rm web bundle exec brakeman
```

## プロジェクト構成

```
ice-breakun2/
├── app/
│   ├── controllers/        # コントローラー
│   ├── models/             # モデル
│   ├── services/           # サービスクラス
│   └── views/              # ビューテンプレート
├── config/
│   ├── database.yml        # データベース設定
│   └── routes.rb           # ルーティング
├── db/
│   ├── migrate/            # マイグレーションファイル
│   └── seeds.rb            # シードデータ
├── spec/                   # テストファイル
├── docker-compose.yml      # Docker Compose設定
├── Dockerfile.dev          # 開発環境用Dockerfile
└── README.md              # このファイル
```

## ライセンス

このプロジェクトは私的使用のためのものです。

## 貢献

1. フィーチャーブランチを作成
2. 変更をコミット
3. テストを実行して通ることを確認
4. プルリクエストを作成

## 詳細情報

- [機能仕様書](.cursor/rules/project-rules.mdc)
