//
//  Child.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/11/03.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import RealmSwift

class Child: Object {
    // 管理用ID。プライマリーキー
    dynamic var id = 0
    
    // 子供の名前
    dynamic var name = ""
    
    // 1人のこどもが複数の約束を持っていると関連付ける
    let promises = List<Promise>()
    
    // 1人のこどもが複数のごほうびを持っていると関連付ける
    let rewards = List<Reward>()
    
    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "id"
    }

}
