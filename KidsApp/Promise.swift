//
//  Promise.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/10/21.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import RealmSwift

class Promise: Object {
    // 管理用 ID。プライマリーキー
    dynamic var id = 0
    
    // やくそくの内容
    dynamic var promisecontents = ""
    
    // やくそくポイント
    dynamic var point = 0
    
    // 完了したやくそく。完了すると true　となる
    dynamic var finished = false
    
    // やくそくを実行した回数をカウントする
    dynamic var count = 0
    
    // 削除ボタンを押したやくそく。削除ボタンを押すと true となる
    dynamic var deleted = false
    
    // やくそくを持っているのはChildクラスの中のpromisesプロパティだと関連づける
    let owners = LinkingObjects(fromType: Child.self, property: "promises")
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
