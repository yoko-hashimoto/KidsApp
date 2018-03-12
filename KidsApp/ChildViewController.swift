//
//  ChildViewController.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/10/13.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import UIKit
import RealmSwift

class ChildViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var childTableView: UITableView!
    
    // Relamインスタンスを取得する
    let realm = try!Realm()
    
    // DB内の子供が格納されるリスト
    // 以降内容をアップデートするとリスト内は自動的に更新される
    var childArray = try!Realm().objects(Child.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        childTableView.delegate = self
        childTableView.dataSource = self
        
        // カスタムした childTableViewCellを使えるように設定する
        let nib = UINib(nibName: "ChildTableViewCell", bundle: nil)
        childTableView.register(nib, forCellReuseIdentifier: "childTableViewCell")
        
        // セルの高さはAutoLayoutに任せる
        childTableView.rowHeight = UITableViewAutomaticDimension
        
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
        return childArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な　cell を得る (cellをカスタムしたchildTableViewCellとして扱う)
        let cell = tableView.dequeueReusableCell(withIdentifier: "childTableViewCell", for: indexPath) as!
            ChildTableViewCell
        
        // 全てのこどもを取得する
        var childArray = try!Realm().objects(Child.self)
        
        // childTableViewCellに値を設定する
        // childArray から indexPath　を使って1人のこどもを取り出す
        let child = childArray[indexPath.row]
        cell.childLabel?.text = child.name
        
            // こどもが持っている(こどもに属している)やくそくをポイントの低い順 (昇順)にソートして取り出す。
            let promises = child.promises.sorted(byKeyPath: "point", ascending: true)
            
            // 実行したやくそくのポイント合計を計算する
            var sumPoint = 0
            for promise in promises {
                sumPoint += promise.point*promise.count
        }
        
            print(sumPoint)
            
            // こどもが持っている(こどもに属している)ごほうびをポイントの低い順 (昇順)にソートして、完了した物だけ取り出す。
            let rewards = (child.rewards.sorted(byKeyPath: "point", ascending: true).filter("finished = true"))
            
            // 実行済のやくそくの合計ポイントから完了したごほうびの合計ポイントを引く
            for reward in rewards {
                sumPoint -= reward.point
            }

            cell.promisePointLabel.text = "\(sumPoint)P"

        return cell
    }
    
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "childSegue", sender: nil)
    }
    
    
    // セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Editボタンが押された時に呼ばれるメソッド
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        childTableView.setEditing(editing, animated: animated)
    }
    
    // 削除可能なセルの indexpath を指定する (全てのCellを削除可能ととする)
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // Realm の書き込みメソッド
            try! realm.write {
                
                // 削除が実行される前に、削除する子供の id を取得する
                let deleteChildID = self.childArray[indexPath.row].id
                
                // データベースから削除する
                self.realm.delete(self.childArray[indexPath.row])
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
                
                // UserDefaults のインスタンス
                let userDefaults = UserDefaults.standard
                
                // childIDが保存されていてたら（子供が選択されていたら）Keyを指定して読み込み(Int型で取り出す)
                if let childId: Int = userDefaults.integer(forKey: "child") {
                    
                    /// 削除するIDと選択中の子供のIDが同じで
                    if deleteChildID == childId {
                        
                        // child Arrayの数が0(子供が他に登録されていない)の時は
                        if childArray.count == 0 {
                            
                            // UserDefaultsから削除する
                            userDefaults.removeObject(forKey: "child")
                            userDefaults.synchronize()
                            
                            // 他に子供が登録されている時は
                        } else {
                            // 登録されている子供のIDの１番目を取り出す
                            let child = self.childArray[0]
                            
                            // 残った子供のidの１番目を、Keyを指定して保存（child型では保存できないので、child.idをInt型で保存）
                            userDefaults.set(child.id, forKey: "child")
                            userDefaults.synchronize()
                        }
                    }
                }
            }
        }
    }
    
    // segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let childInputViewController: ChildInputViewController = segue.destination as! ChildInputViewController
        
        if segue.identifier == "childSegue" {
            let indexPath = self.childTableView.indexPathForSelectedRow
            childInputViewController.child = childArray[indexPath!.row]
        } else {
            let child = Child()
            
            if childArray.count != 0 {
                child.id = childArray.max(ofProperty: "id")! + 1
            }
            
            childInputViewController.child = child
        }
        
    }
    
    // 入力画面から戻ってきた時にChildTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        childTableView.reloadData()
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
