# foltia-docker-mirakurun

## 準備

- docker と docker-compose が導入済みのLinux(x86_64)環境 (Ubuntu 20.04LTSで動作確認)
- Mirakurun (3.8.0 で動作確認)

## セットアップ

```
git clone https://github.com/kyuntx/foltia-docker-mirakurun.git
cd foltia-docker-mirakurun/
./setup
```
物理アプライアンス用のディスクイメージをそのまま変換して docker に import するため、かなり時間がかかります。

## 設定

- docker-compose.yml にて、最低 Mirakurun のホスト・ポートを設定
```
    environment:
      MIRAKURUN: mirakurun:40772
```
- phpPgAdmin, Shell-in-a-box, MiniDLNA, Samba はデフォルト無効です（foltia に入っているバージョンは古いため、セキュリティ的にもオススメしません）。動作確認もしていません。(Sambaはホスト側で設定するのがよいです)
```
    environment:
      ENABLE_PHPPGADMIN: 0
      ENABLE_SHELLINABOX: 0
      ENABLE_MINIDLNA: 0
      ENABLE_SAMBA: 0
```
 - MiniDLNA, Samba を有効にする場合は、ポートの開放も行います
```
    ports:
      - 80:80
      #- 139:139       # samba
      #- 445:445       # samba
      #- 138:138       # samba
      #- 8200:8200     # minidlna
      #- 1900:1900/udp # minidlna
```
- そのままでも動きますが、録画データの保存先やデータベースの保存場所など、必要に応じてカスタマイズしてください
```
    volumes:
      - ./data/db:/var/opt/rh/rh-postgresql95/lib/pgsql/data
      - ./data/at:/var/spool/at
      - ./data/cron:/var/spool/cron
      - ./tv:/home/foltia/php/tv
      - ./neroAacEnc/linux/neroAacEnc:/home/foltia/perl/tool/neroAacEnc
```
 - 既存の（物理）foltiaから移行する場合、/var/opt/rh/rh-postgresql95/lib/pgsql/data を ./data/db に、/home/foltia/php/tv を ./tv (または参照先)にコピーするこで、同一バージョンであれば移行できるかもしれません。

 ## 起動
 ```
 docker-compose up -d
 ```

 ## 停止
 ```
 docker-compose down
 ```