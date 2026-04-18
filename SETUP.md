# セットアップ手順

## 事前インストール

| ツール | URL | 備考 |
|---|---|---|
| Git | https://git-scm.com | |
| Docker Desktop | https://www.docker.com/products/docker-desktop | 起動しておく |
| Ollama | https://ollama.com | AI機能に必要 |

Ollama インストール後、ターミナルで以下を実行：

```bash
ollama pull llama3.2
```

---

## セットアップ

```bash
# 1. リポジトリをクローン
git clone https://github.com/taiyou1104/my-dashboard-app.git
cd my-dashboard-app

# 2. master.key を作成
echo "8607956067511c79d4ee4f785e7ae26c" > config/master.key

# 3. .env ファイルを作成（Ollama は API キー不要）
touch .env

# 4. 起動
docker compose up -d

# 5. DB初期化（初回のみ）
docker compose exec web bundle exec rails db:migrate
```

ブラウザで http://localhost:3000 を開く。

---

## 2回目以降の起動

```bash
docker compose up -d
```

## 停止

```bash
docker compose down
```

## コードを最新にする

```bash
git pull
docker compose exec web bundle exec rails db:migrate
```
