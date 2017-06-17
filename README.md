# matome channel server

[![CircleCI](https://circleci.com/gh/tanik/matome_channel_server.svg?style=svg)](https://circleci.com/gh/tanik/matome_channel_server)

# 概要

まとめちゃんねる(<http://m-ch.xyz>)のサーバサイドの実装 by Rails 5.1

# 依存サービス

- mysql
- redis
- elasticsearch
- AWS API GATEWAY
- AWS Lambda(API Gatewayの先のWebshotで使用)
- Slack(error notification, contact notification)

# 環境変数

```.env```ファイルに以下を設定

| 変数名 | 説明 |
|-|-|
| SIDEKIQ_REDIS_URL             | Sidekiq向けのRedis URL (ex. redis://localhost:6379/1) |
| SIDEKIQ_USERNAME              | Sidekiq web画面の認証用ユーザ名 |
| SIDEKIQ_PASSWORD              | Sidekiq web画面の認証用パスワード |
| CABLE_REDIS_URL               | action cable向けのRedis URL (ex. redis://localhost:6379/1) |
| HASH_SECRET                   | コメントHASH ID作成用Secret |
| AWS_S3_BUCKET                 | S3 bucket名 |
| AWS_S3_ENDPOINT               | S3エンドポイントURL (http://example.bucket.s3-website-ap-northeast-1.amazonaws.com/) |
| API_GATEWAY_KEY               | API KEY Gateway(generate by aws console) |
| API_GATEWAY_ENDPOINT          | API GatewayエンドポイントURL(ex. https://example.execute-api.ap-northeast-1.amazonaws.com/dev) |
| ELASTICSEARCH_URL             | Elastic Search URL (ex. localhost:9200) |
| SLACK_WEBHOOK_FOR_ERROR_URL   | Error Notification用WEBFOOK URL(ex. https://hooks.slack.com/services/example1) |
| SLACK_WEBHOOK_FOR_CONTACT_URL | お問い合わせ通知用WEBFOOK URL(ex. https://hooks.slack.com/services/example1) |

# テスト

~~~
bundle exec rspec
~~~

# デプロイ/CI

### デプロイコマンド

~~~
bundle exec cap {env} deploy
~~~

env=staging\|production

### CI

[CircleCI](https://circleci.com)を使用。設定はcircle.yml参照。
masterにpushするとてtestしてdeployしてくれる。

# 関連リポジトリ

- フロントエンド: [matome_chanel_client](https://github.com/tanik/matome_channel_client)
- Lambda用website screenshot取得関数: [webshot_on_lambda](https://github.com/tanik/webshot_on_lambda)
- Lambda用image screenshot取得関数: [getimage_on_lambda](https://github.com/tanik/getimage_on_lambda)
- サーバ初期設定用ansible playbook: [matome_channel_setup](https://github.com/tanik/matome_channel_setup)
