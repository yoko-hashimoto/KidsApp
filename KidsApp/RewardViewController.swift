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
import CMPopTipView

class RewardViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var rewardTableView: UITableView!
    @IBOutlet weak var rewardAddButton: UIBarButtonItem!
    
    // lazy var は変数が参照されたときに { }() の中で初期化した値を使う
    lazy var cmPop: CMPopTipView = {
        
        // CMPopTipViewのメッセージ
        let v = CMPopTipView(message: "ポイントが貯まったらごほうびGET!")!
        
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
    
    // lazy var は変数が参照されたときに { }() の中で初期化した値を使う
    lazy var cmPop2: CMPopTipView = {
        // navigationBarのCMPopTipViewのメッセージ
        let v = CMPopTipView(message: "欲しいごほうびを登録！")!
        
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
    
    // Realmインスタンスを取得する
    let realm = try!Realm()
    
    // DB内のごほうびが格納されるリスト
    // 完了していない順ソート： (昇順)
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var rewardArray = try!Realm().objects(Reward.self).sorted(byKeyPath: "finished", ascending: true).filter("FALSEPREDICATE")
    
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
        
        //編集中の場合はGETボタンを無効化
        if self.rewardTableView.isEditing {
            cell.getButton.isEnabled = false
            
            // 編集中でない場合はGETボタンを有効化
        } else {
            cell.getButton.isEnabled = true
        }
        
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
        
        // セルの中のGETボタンタップ時にハイライトさせるかどうかの設定
        cell.getButton.showsTouchWhenHighlighted = true
        // セルの中のGETボタンタップ時にハイライトさせる設定を取得
        let _ : Bool = cell.getButton.showsTouchWhenHighlighted
        
        // セルの中のGETボタンを角丸にする
        cell.getButton.layer.cornerRadius = 10
        
        return cell
    }
    
    // セルの中のGETボタンがタップされた時に呼ばれるメソッド
    func handleGetButton(sender: UIButton, event:UIEvent) {
        
        // アラートコントローラーを使って、ごほうびGETの確認画面を表示する
        // ① アラートコントローラーの実装
        let alertController = UIAlertController(title: "ごほうび",message: "ごほうびをGETしますか？", preferredStyle: UIAlertControllerStyle.alert)
        
        // ②-1 アラートコントローラーのOKボタンの実装
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            
        // ②-2 アラートコントローラーのOKボタンがタップされた時の処理
        // タップされたボタンのセルのインデックス(場所)を求める　→　どのやくそくか
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.rewardTableView)
        let indexPath = self.rewardTableView.indexPathForRow(at: point)
        
        // rewardArrayからGETボタンをタップされたインデックスのやくそくを取り出す
        let rewardData = self.rewardArray[indexPath!.row]
        
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
                    try! self.realm.write {
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
        self.rewardTableView.reloadData()
            
        }
        
        // アラートコントローラーのCANCELボタンの実装
        let cancelButton = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: nil)
        
        // ③-1 OKボタンの追加
        alertController.addAction(okAction)
        // ③-2 CANCELボタンの追加
        alertController.addAction(cancelButton)
        
        // ④ アラートの表示
        present(alertController,animated: true,completion: nil)
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
        
        // rewardTableViewを更新し、セルの中のOKボタンのisEnabledを切り替える(編集中なので、無効にする)
        rewardTableView.reloadData()
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
                
                // そのごほうびをGETしていなかったら(finished が false だったら)
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
            
            // CMPopTipViewの表示を消す
            cmPop2.dismiss(animated: true)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // UserDefaults のインスタンス
        let userDefaults = UserDefaults.standard
        
        // まだ表示したことがない（pop_reward_get が false のとき）時だけ、cmPopを表示する
        if userDefaults.bool(forKey: "pop_reward_get") == false {
            
            // 表示されている最初のセルを取り出す
            // 1. 見えているセルの IndexPath の配列を rewardTableView.indexPathsForVisibleRows で取り出す
            // 2. 最初の要素を first で取り出せば、見えているセルのうち一番上の IndexPath が取り出せる
            // 3. 見えているセルうち最初の IndexPath を元にセルを取り出し、RewardTableViewCell にキャストする
            if let indexPath = rewardTableView.indexPathsForVisibleRows?.first {
                if let cell = rewardTableView.cellForRow(at: indexPath) as? RewardTableViewCell {
                
                    // 場所を指定してCMPopTipViewを表示
                    cmPop.presentPointing(at: cell.getButton, in: self.view, animated: true)
                    
                    // 次回は表示されないように pop_reward_get を true で保存する
                    userDefaults.set(true, forKey: "pop_reward_get")
                    userDefaults.synchronize()
                }
            }
        }
        
        // まだ表示したことがない（pop_reward_add が false のとき）時だけ、cmPopを表示する
        if userDefaults.bool(forKey: "pop_reward_add") == false {
            
            // 場所を指定してCMPopTipViewを表示
            cmPop2.presentPointing(at: rewardAddButton, animated: true)
            
            // 次回は表示されないように pop_reward_add を true で保存する
            userDefaults.set(true, forKey: "pop_reward_add")
            userDefaults.synchronize()
            
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
