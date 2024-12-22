# OpenAPI の仕様書を元に Postman のコレクションを自動更新する Docker コンテナ

## 概要

OpenAPI の仕様書を Postman に import し、コレクションを生成していると下記の不満点があげられる。

- 毎回新しいコレクションとして作成されるため、更新するたびに変数を用意する必要がある
- 共通のパスパラメーターの部分を毎回置き換えるのが面倒
  例：「`https://api.example.com/facilities/:facilityId/users`」\
  →「`https://api.example.com/facilities/{{facilityId}}/users`」

上記の不満点を改善するため、Postman のコレクションを自動更新する Docker コンテナを作成した。

## 用意するもの

- OpenAPI Specification ファイル

## 事前準備

### 1. APIKey とコレクション ID を用意する

#### APIKey

Postman の**プロフィール画面** → 「**EditProfile**」 → 「**API Keys**」
「**Generate API Key**」で APIKey を作成。

#### コレクション ID

コレクションの三点マーク「•••」→「**Share（共有）**」→ 「**Via API(API 経由)**」のタブを開く

```
https://api.postman.com/collections/{{collection_id}}?access_key=
```

の`{{collection_id}}`の部分がコレクション ID となる

### 2. APIKey・CollectionID・PathParameter を環境変数として定義する

`.env`

```
POSTMAN_API_KEY=
POSTMAN_COLLECTION_ID=
OPENAPI_FILE_PATH=
PATHPARAMETERS=
```

| 環境変数名        | 説明                                                                        | 例                                                                                            |
| ----------------- | --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| OPENAPI_FILE_PATH | マウント先の OpenAPI のファイル Path （**/忘れずに**）                      | `./internal/docs/openapi.json:/openapi.json`とした場合<br> `OPENAPI_FILE_PATH=/openapi.json ` |
| PATHPARAMETERS    | Postman の変数に置き換えたい PathParameter を定義する（半角スペース区切り） | `PATHPARAMETERS=facility_id position_id department_id team_id position_id`                    |

## docker-compose を利用する場合

### 3. サービスを定義

```
services:
  ...（他のコンテナ定義）
  postman_collection_update:
    image: fukuemon/postman_collection_update
    volumes:
      - ./openapi.json:/openapi.json
    env_file:
      - .env
```

### 4. サービスの実行

```
docker-compose run --rm postman_collection_update
```

or

```
docker compose run --rm postman_collection_update
```

## 単一のコンテナとして利用する場合

### 3. コンテナイメージをダウンロード・ローカルにビルド

```
docker pull fukuemon/postman_collection_update
```

### 4. コンテナの実行

```
docker run --env-file .env -v $(pwd)/{{OpenAPIのファイルpath}}:/{{OpenAPIのファイルpath}} --rm postman_collection_update
```

例：

```
docker run --env-file .env -v $(pwd)/openapi.json:/openapi.json --rm fukuemon/postman_collection_update
```
