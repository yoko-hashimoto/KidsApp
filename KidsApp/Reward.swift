//
//  Reward.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/11/02.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import RealmSwift

class Reward: Object {
    // 管理用ID。プライマリーキー
    dynamic var id = 0
    
    // ごほうびの内容
    dynamic var rewardcontents = ""
    
    // ごほうびポイント
    dynamic var point = 0
    
    // 完了したごほうび。完了すると true　となる
    dynamic var finished = false
    
    // 削除ボタンを押したやくそく。削除ボタンを押すと true となる
    dynamic var deleted = false
    
    // ごほうびを持っているのはChildクラスのrewardsプロパティだと関連づける
    let owners = LinkingObjects(fromType: Child.self, property: "rewards")
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
