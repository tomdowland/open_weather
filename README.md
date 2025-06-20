# Open Weather

Flutter test project for Baleen Studio
バリーンスタジオ の Flutter テストプロジェクト

## Features/機能

- City search
- Dark mode
- Geolocation

- 都市検索
- ダークモード
- 位置情報（ジオロケーション）

## Architecture/アーキテクチャ

UI Layer
- Use ConsumerWidgets for views: Home Page and Settings Page

Application Layer
- The provider classes consume methods from the network services to deliver data to UI organised into models.

Data Layer
- API service and repository,and weather models retrieve data form the API endpoint and process through providers to reach UI layer. The repository offers a clean endpoint for the provider to consume.

UI レイヤー
- ビューには ConsumerWidgets を使用します：ホーム画面と設定画面

アプリケーションレイヤー
- プロバイダクラスは、ネットワークサービスからのメソッドを消費し、モデルに整理されたデータを UI に提供します。

データレイヤー
- API サービスとリポジトリ、そして天気モデルは、API エンドポイントからデータを取得し、プロバイダを介して UI レイヤーに処理します。リポジトリは、プロバイダが消費するためのクリーンなエンドポイントを提供します。

## Reasoning/選定理由
I chose Riverpod for state management in this case in part due to familiarity, but also ease of use. Using Riverpod in combination with freezed for model generation, it is possible to have  a variety of variables available for use in many classes and views without the need for passing variables back and forth through navigation.
Riverpod offers a very smooth responsive experience that allows for an extra level of abstraction between the view provider layer and the network service.
The app uses GoRouter for navigation as it provides an easy and light way to implement navigation between pages.

Thinking about how the app should behave on startup, rather than have the user input a city name into the search field, the app uses geolocator to find the user's location and display weather data from this location.

The Open Weather API will only give responses in a given language when the request is made with that language setting as a request parameter, so when the language setting is changed, a new call is made to the API for data.

今回、Riverpod を状態管理に選んだのは、使い慣れていることに加えて、その使いやすさも理由です。Riverpod を Freezed と組み合わせてモデル生成に使用することで、多くのクラスやビューで様々な変数を、ナビゲーションを介して変数をやり取りすることなく利用できるようになります。
Riverpod は非常にスムーズな応答性を提供し、ビューとプロバイダレイヤー、そしてネットワークサービスとの間にさらなる抽象化レベルを可能にします。
アプリは GoRouter をナビゲーションに使用しています。これは、ページ間のナビゲーションを簡単かつ軽量に実装できるためです。

アプリの起動時の動作について考えると、ユーザーが検索フィールドに都市名を入力するのではなく、アプリは geolocator を使用してユーザーの現在地を特定し、その場所の天気データを表示します。

Open Weather API は、リクエストが言語設定をリクエストパラメータとして行った場合にのみ、指定された言語で応答を返します。そのため、言語設定が変更されると、新しいデータ取得のために API への新しい呼び出しが行われます。
