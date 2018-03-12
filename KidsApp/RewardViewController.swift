//
//  RewardViewController.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/10/13.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD

class RewardViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var rewardTableView: UITableView!
    
    // Realmインスタンスを取得する
    let realm = try!Realm()
    
    // DB内のごほうびが格納されるリスト
    // 完了していない順ソート： (昇順)
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var rewardArray = try!Realm().objects(Reward.self).sorted(byKeyPath: "finished", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // テーブルセルのタップを無効にする
        rewardTableView.allowsSelection = false
        
        rewardTableView.delegate = self
        rewardTableView.dataSource = self
        
        // カスタムした rewardTableViewCellを使えるように設定する
        let nib = UINib(nibName: "RewardTableViewCell", bundle: nil)
        rewardTableView.register(nib, forCellReuseIdentifier: "rewardTableViewCell")
        
        // セルの高さは AutoLayoutに任せる
        rewardTableView.rowHeight = UITableViewAutomaticDimension
        
        // Edit ボタンを左上に配置
        navigationItem.leftBarButtonItem = editButtonItem
        
        // ナビゲーションバー上のアイテムの色をピンクに設定する
        let pinkColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 128.0/255.0, alpha:1)
        self.navigationController?.navigationBar.tintColor = pinkColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // データの数(=セルの数)を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewardArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な　cell を得る　(cellをカスタムしたrewardTableViewCellをとして扱う)
        let cell = tableView.dequeueReusableCell(withIdentifier: "rewardTableViewCell", for: indexPath) as!
            RewardTableViewCell
        
        // rewardTableViewCellに値を設定する
        let reward = rewardArray[indexPath.row]
        // ごほうびの内容を表示する
        cell.rewardLabel?.text = reward.rewardcontents
        // ごほうびのポイントを表示する
        cell.rewardPointLabel?.text = "\(reward.point)P"
        
        // セルの中のGETボタンをタップすると handleGetButton のメソッドが呼ばれる。ボタンをタップして指を話した時に。
        cell.getButton.addTarget(self, action: #selector(handleGetButton(sender:event:)), for: UIControlEvents.touchUpInside)
        
        
        // ごほうびをGETしていなかったら(finished が false の時)
        if reward.finished == false {
            
            // セルの中のGETボタンを"GET"と表示させる
            cell.getButton.setTitle("GET", for: .normal)
            // セルの中のGETボタンを押せるようにする
            cell.getButton.isEnabled = true
            
            // ごほうびがGET済だったら(finishedがtrueの時)
        } else {
            
            // セルの中のGETボタンを"GET済"に変える
            cell.getButton.setTitle("GET済", for: .normal)
            // セルの中のGETボタンを押せないようにする
            cell.getButton.isEnabled = false
        }
        
        // セルの中のOKボタンを角丸にする
        cell.getButton.layer.cornerRadius = 10
        
        return cell
    }
    
    // セルの中のGETボタンがタップされた時に呼ばれるメソッド
    func handleGetButton(sender: UIButton, event:UIEvent) {
        
        // タップされたボタンのセルのインデックス(場所)を求める　→　どのやくそくか
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.rewardTableView)
        let indexPath = rewardTableView.indexPathForRow(at: point)
        
        // rewardArrayからGETボタンをタップされたインデックスのやくそくを取り出す
        let rewardData = rewardArray[indexPath!.row]
        
        // UserDefaults のインスタンス
        let userDefaults = UserDefaults.standard
        
        // childIDが保存されていてたら（子供が選択されていたら）Keyを指定して読み込み(Int型で取り出す)
        if let childId: Int = userDefaults.integer(forKey: "child") {
            
            // UserDefaultsに保存されている child.id を元に、選択中の子供を取り出す
            let predicate = NSPredicate(format: "id == %d", childId)
            let children = try!Realm().objects(Child.self).filter(predicate)
            
            // 子供が選択されていれば以下の内容を実行する
            if let child = children.first {
                
                // こどもが持っている(こどもに属している)やくそくをポイントの低い順 (昇順)にソートして取り出す
                let promises = child.promises.sorted(byKeyPath: "point", ascending: true)
                
                // 実行済のやくそくポイントの合計を計算する
                var sumPoint = 0
                for promise in promises {
                    sumPoint += promise.point*promise.count
                }
                
                
                // こどもが持っている(こどもに属している)ごほうびをポイントの低い順 (昇順)にソートして、完了した物だけ取り出す。
                let rewards = child.rewards.sorted(byKeyPath: "point", ascending: true).filter("finished = true")
                
                // 実行済のやくそくポイントの合計から完了済のごほうびポイントの合計を引く
                for reward in rewards {
                    
                    // sumPoint → 今持っている合計ポイント
                    sumPoint -= reward.point
                }
                
                // 今持っている合計ポイントがGETボタンを押したごほうびのポイントより大きい場合
                if sumPoint >= rewardData.point {
                    
                    // 今持っている合計ポイントからGETボタンを押したごほうびのポイントを引いて代入する
                    sumPoint -= rewardData.point
                    
                    // Realm の書き込みのメソッドを使って finished を true にする →　ごほうびをGET済にする
                    try! realm.write {
                        rewardData.finished = true
                    }
                    
                    
                } else {
                    
                    // 今持っているポイントが足りない時はモーダルでエラー表示をさせる
                    SVProgressHUD.showError(withStatus: "ポイントが足りません")
                    return
                }
            }
        }
        
        // tableViewを更新してボタンの表示を変える
        rewardTableView.reloadData()
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "rewardSegue", sender: nil)
    }
    
    // セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Editボタンが押された時に呼ばれるメソッド
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        rewardTableView.setEditing(editing, animated: animated)
    }
    
    // 削除可能なセルの indexpath を指定する (全てのCellを削除可能ととする)
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // indexPath を使って、その行のごほうびを取得する
            let reward = rewardArray[indexPath.row]
            
            // そのごほうびをGETしていたら(finished が　true だったら)
            if reward.finished == true {
                
                // Realm の書き込みメソッドを使って、そのご褒美を削除済みにする(deletedをtrueにする)
                try! realm.write {
                    reward.deleted = true
                    
                    // promiseTableView の「表示」(見た目)から該当のセルをアニメーション付きで削除する
                    tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
                }
                
                // そのごほうびをGETしていなかったら(finished が　false だったら)
            } else {
                try! realm.write {
                    // データを削除する
                    self.realm.delete(rewardArray[indexPath.row])
                    
                    // rewardTableView の「表示」（見た目）から該当のセルをアニメーション付きで削除する
                    rewardTableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
                }
            }
        }
    }
    
    // segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let rewardInputViewController: RewardInputViewController = segue.destination as! RewardInputViewController
        
        // segueのIdentifierがrewardSegue(セルをタップした)の時
        if segue.identifier == "rewardSegue" {
            let indexPath = self.rewardTableView.indexPathForSelectedRow
            rewardInputViewController.reward = rewardArray[indexPath!.row]
            
            // セルをタップした時は編集なので isNewReward は falseとする
            rewardInputViewController.isNewReward = false
            
            // +ボタンをタップした時
        } else {
            let reward = Reward()
            
            // 子供ごとではなく全てのごほうびを取得する
            let allRewards = realm.objects(Reward.self)
            if allRewards.count != 0 {
                // すでに存在しているごほうびのidの内、最大のものを取得し、1を足すことで他のidと重ならない値を指定する
                reward.id = allRewards.max(ofProperty: "id")! + 1
            }
            
            rewardInputViewController.reward = reward
            
            // ＋ボタンをタップした時は新規登録なので isNewReward は true とする
            rewardInputViewController.isNewReward = true
        }
    }
    
    // 入力画面から戻ってきた時にRewardTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // UserDefaults のインスタンス
        let userDefaults = UserDefaults.standard
        
        // childIDが保存されていてたら（子供が選択されていたら）Keyを指定して読み込み(Int型で取り出す)
        if let childId: Int = userDefaults.integer(forKey: "child") {
            
            // UserDefaultsに保存されている child.id を元に、選択中の子供を取り出す
            let predicate = NSPredicate(format: "id == %d", childId)
            let children = try!Realm().objects(Child.self).filter(predicate)
            
            // childrenは配列なので、その中から最初の子供を取り出し、以下の内容を実行する
            if let child = children.first {
                
                // こどもが持っている(こどもに属している)ごほうびを完了した順(昇順)にソートし、未削除(削除ボタンを押していない物)のみ取り出す
                rewardArray = child.rewards.sorted(byKeyPath: "finished", ascending: true).filter("deleted = false")
                
                rewardTableView.reloadData()
                
                // navigationBarにタイトルをセットする
                self.navigationItem .title = child.name
                
                // フォントをサイズを22に指定
                self.navigationController?.navigationBar.titleTextAttributes
                    = [NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 22)!]
                
                
                // こどもが選択されていなければアラートを出す
            } else {
                SVProgressHUD.showError(withStatus: "こどもを選択してください")
            }
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
