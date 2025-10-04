# Inception
42 project

## 概要

### 使ったリソースメモ
[WP-CLIインストール手順](https://wp-cli.org/#installing)
[Bakr-1 / inceptionVm-guide](https://github.com/Bakr-1/inceptionVm-guide)
https://github.com/Vikingu-del/Inception-Guide?tab=readme-ov-file
https://developer.wordpress.org/advanced-administration/wordpress/wp-config/



### 全体
- VMを使う
- srcs に全てのconfigファイルを置く
- app全体を設定するMakefileがrootにあること (to build the Docker images; docker-compose.ymlを呼ぶ)
- documentationをたくさん読む

### 用語

Dockerfile:	imageのbuild用。コンテナ実行のための依存関係・設定が書かれたファイル
docker-compose.yml 	複数のコンテナを管理; Dockerfileを指定することができる
penultimate stable: ひとつ前の安定版

### Mandatory

Docker Compose を使って、次のサービスをVM上で構築する

- [ ] Docker imageの名前は、serviceと一致させる -> container_name:
- [ ] 各serviceは、専用のコンテナでrunする
- [ ] the penultimate stable version の VM (Alpine or Debian) を使う
- [ ] service毎の`Dockerfiles`を書く
- [ ] Makefile -> docker-compose.yml -> `Dockerfiles` の呼び出し
- [ ] 用意されたDocker imagesは使用不可; 自分でimagesをbuildする

セットアップ
- [ ] NGINX（ポート443、TLS v1.2/1.3のみ）
- [ ] WordPress（php-fpmのみ、nginxなし）installed + configured
- [ ] MariaDB（nginxなし）
- [ ] Docker volumes: DB用
- [ ] Docker volumes: WordPressサイトファイル用
- [ ] docker-network によるコンテナ間の接続を確立する (network line 必須 docker-compose.yml)
- [ ] crash時には自動的に再起動

forbidden
- [ ] `network: host`, `--link`, or `links:` は禁止
- [ ] inf loop を使って、簡易的に動かし続けてはならない (ex. tail -f, bash, sleep infinity, while true)

info: `PID 1` について読み、Dockerfilesの最善を調べる

WordPress database
- [ ] administratorを含む、2人のuserが必要
- [ ] Administratorのuser nameはadminやadministratorを使用しない

info: `/home/login/data` に、volumesが用意される。loginは自分のものに変える

- [ ] local の IPアドレスを指すdomain name `sakitaha.42.fr` を設定する

注意
- [ ] latest tagは禁止
- [ ] passwordはDockerfilneにおいて指定される
- [ ] 環境変数の利用は必須
- [ ] .envファイルを使って、環境変数を蓄積し、機密情報はdocker secretsを用いる
- [ ] NGINX コンテナが唯一のentry pointになる (port 443, TLSv1.2 or TLSv1.3)


For obvious security reasons, any credentials, API keys, passwords,
etc., must be saved locally in various ways / files and ignored by
git. Publicly stored credentials will lead you directly to a failure
of the project

### Bonus

- [ ] bonusで追加されるserviceは、それぞれのDockerfileを持つ
- [ ] 各serviceはそれぞれのコンテナで作動し、必要に応じて専用のvolumeを持つ

list
- [ ] WordPress 網站のcache管理のため、redis casheを設定する
- [ ] WordPress 網站のvolumeを指す、FTP serverを設定する
- [ ] PHP以外の言語で、単純かつ静的な網站
- [ ] `Adminer` を設定する
- [ ] 自分が便利だと思う任意のserviceを設定する。 (要defence)

bonusは、mandatoryがすべて完璧な時にのみ評価される





❌ 禁止事項：
	•	tail -f, while true, sleep infinity などの無限ループ起動
	•	--link, network: host, latestタグの使用
	•	DockerHubからpull（Alpine/Debianベース以外）
	•	パスワード直書き



## Resources

https://hub.docker.com/_/mariadb/


## To-do: reading list

https://github.com/Vikingu-del/Inception-Guide

https://github.com/zelhajou/ft_sys_inception

https://medium.com/@abdelhadi-salah/mastering-docker-a-deep-dive-into-the-inception-project-at-42-7545749332fc

Docker/Kubernetes で PID 1 問題を回避する
https://text.superbrothers.dev/200328-how-to-avoid-pid-1-problem-in-kubernetes/






ローカルから openssl コマンドで特定のバージョンを指定して接続してみる。

# TLS1.2で接続を試みる
openssl s_client -connect sakitaha.42.fr:443 -tls1_2

# TLS1.3で接続を試みる
openssl s_client -connect sakitaha.42.fr:443 -tls1_3

# 古いバージョンで試してみる (これが失敗すればOK)
openssl s_client -connect sakitaha.42.fr:443 -tls1_1
openssl s_client -connect sakitaha.42.fr:443 -tls1

→ 1.2 と 1.3 が成功して、1.1 と 1.0 が失敗すれば要件クリア 


https://github.com/Bakr-1/inceptionVm-guide