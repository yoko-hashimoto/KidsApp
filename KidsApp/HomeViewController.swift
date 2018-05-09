//
//  HomeViewController.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/10/13.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import UIKit
import SVProgressHUD
import RealmSwift
import CMPopTipView

class HomeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var rewardLabel: UILabel!
    @IBOutlet weak var rewardPointLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var switchButton: UIButton!

    var promiseArray:[Promise] = []
    var rewardArry:[Reward] = []
    
    // lazy var は変数が参照されたときに { }() の中で初期化した値を使う
    lazy var cmPop: CMPopTipView = {
        
        // CMPopTipViewのメッセージ
        let v = CMPopTipView(message: "こども切替えはココをタップ")!
        
        // CMPopTipViewのborderColor
        v.borderColor = UIColor.clear
        
        // CMPopTipViewの背景色
        v.backgroundColor = UIColor.orange
        
        // 3D表示にするかどうか
        v.has3DStyle = false
        
        // グラデーション表示にするかどうか
        v.hasGradientBackground = false
        
        return v
    }()

    // switchingButton をタップした時に CMPopTipView の表示を消す
    @IBAction func switchingButton(_ sender: Any) {
        
        cmPop.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 自作の関数
    func setChild() {
        
        // UserDefaults のインスタンス
        let userDefaults = UserDefaults.standard
        
        // childIDが保存されていてたら（子供が選択されていたら）Keyを指定して読み込み(Int型で取り出す)
        if let childId: Int = userDefaults.integer(forKey: "child") {
            
            // UserDefaultsに保存されている child.id を元に、選択中の子供を取り出す
            let predicate = NSPredicate(format: "id == %d", childId)
            let children = try!Realm().objects(Child.self).filter(predicate)
            
            // childrenは配列なので、その中から最初の子供を取り出し、以下の内容を実行する
            if let child = children.first {
                
                nameLabel.text = child.name
                
                // こどもが持っている(こどもに属している)やくそくをポイントの低い順 (昇順)にソートして取り出す。
                let promises = child.promises.sorted(byKeyPath: "point", ascending: true)
                
                // 実行したやくそくのポイント合計を計算する
                var sumPoint = 0
                for promise in promises {
                    sumPoint += promise.point*promise.count
                }
                
                print(sumPoint)
                
                // こどもが持っている(こどもに属している)ごほうびをポイントの低い順 (昇順)にソートして、完了した物だけ取り出す。
                let rewards = child.rewards.sorted(byKeyPath: "point", ascending: true).filter("finished = true")
                
                // 実行済のやくそくの合計ポイントから完了したごほうびの合計ポイントを引く
                for reward in rewards {
                    sumPoint -= reward.point
                }
                
                // pointLabel に今持っているポイントを表示する
                pointLabel.text = "\(sumPoint) P"
                
                // こどもが持っている(こどもに属している)ごほうびの内、完了していない物を取り出す。
                let unFinished = child.rewards.filter("finished = false")
                
                // 完了していないごほうびの中から最初に登録した物が取り出せた場合
                if let firstReward = unFinished.first {
                    
                    // rewardLabel.text に　そのごほうびの内容を表示させる
                    rewardLabel.text = "\(firstReward.rewardcontents)"
                    
                    // rewardPointLabel.text にそのやくそくのポイントを表示させる
                    rewardPointLabel.text = "\(firstReward.point) P で GET !"
                    
                    // 完了していないやくそくの中から最初に登録した物が取り出せなかった場合
                } else {
                    rewardLabel.text = "ごほうびを登録して下さい"
                    
                    //　 rewardPointLabel.text は空白にする　→　何も表示させない為に
                    rewardPointLabel.text = ""
                }
            }
           
            // childIDが保存されていなかった場合（子供が選択されていなかった場合）の表示
        } else {
            nameLabel.text = "なまえ"
            pointLabel.text = "(  ) P"
            rewardPointLabel.text = "(  ) P で GET !"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // nameLabelを角丸にする
        nameLabel.layer.cornerRadius = 10
        nameLabel.clipsToBounds = true
        
        setChild()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // UserDefaults のインスタンス
        let userDefaults = UserDefaults.standard
        
        // まだ表示したことがない（pop_switchButton が false のとき）だけ、cmPopを表示する
        if userDefaults.bool(forKey: "pop_switchButton") == false {
            
            // 場所を指定してCMPopTipViewを表示
            cmPop.presentPointing(at: switchButton, in: self.view, animated: true)
            
            // 次回は表示されないように pop_switchButton を true で保存する
            userDefaults.set(true, forKey: "pop_switchButton")
            userDefaults.synchronize()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        
        if segue.source is ChildSwitchViewController {
            
            setChild()
        }
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
