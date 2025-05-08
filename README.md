# alarm_project

## 作業開始時
1. 最新ブランチの取得
```bash
git checkout main
git pull origin main
```

2. 新しいブランチの作成
``` bash
git checkout {branch_name}
```

## 作業終了時
1. 変更のコミット
``` bash
git add .
git commit -m "変更内容の記載"
```
2. リモートにプッシュ
``` bash
git push origin {branch_name}
```
3. プルリクエストの作成
- githubでプルリクエストの作成
- mainとマージする

## iPhoneでビルドできない時
1. Flutter パッケージを取得し直す:
```
flutter pub get
```
2. iOS プロジェクトをリビルドする:
```
cd ios
pod install
cd ..
```
3. プロジェクト全体をクリーンアップして再ビルドする:
```
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run
```
