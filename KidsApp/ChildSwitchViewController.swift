//
//  ChildSwitchViewController.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/11/11.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import UIKit
import RealmSwift

class ChildSwitchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var childSwitchTableView: UITableView!
    
    // DB内の子供が格納されるリスト
    // 以降内容をアップデートするとリスト内は自動的に更新される
    // こども一覧を取得する
    var childArray = try!Realm().objects(Child.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        childSwitchTableView.delegate = self
        childSwitchTableView.dataSource = self
        
        // カスタムした childSwitchTableViewCellを使えるように設定する
        let nib = UINib(nibName: "ChildSwitchTableViewCell", bundle: nil)
        childSwitchTableView.register(nib, forCellReuseIdentifier: "childSwitchTableViewCell")
        
        // セルの高さはAutoLayoutに任せる
        childSwitchTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // データの数（=セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return childArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な　cell を得る　(cellをカスタムした　childSwitchTableViewCell　として扱う)
        let cell = tableView.dequeueReusableCell(withIdentifier: "childSwitchTableViewCell", for: indexPath) as! ChildSwitchTableViewCell
        
        // childSwitchTableViewCellに値を設定して、セルに表示させる
        let child = childArray[indexPath.row]
        cell.childSwitchLabel?.text = child.name
        
        return cell
    }
    
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // childArrayから選択したこどものデータを取得する
        let child = childArray[indexPath.row]
        
        // UserDefaults のインスタンス
        let userDefaults = UserDefaults.standard
        
        // 選択した子供のidを、Keyを指定して保存（child型では保存できないので、child.idをInt型で保存）
        userDefaults.set(child.id, forKey: "child")
        userDefaults.synchronize()

        // 画面を閉じる
        performSegue(withIdentifier: "back", sender: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            if tag == 1 {

                performSegue(withIdentifier: "back", sender: nil)
            }
        }
    }
    
    @IBAction func childSwitchCancelButton(_ sender: Any) {
        
        performSegue(withIdentifier: "back", sender: nil)
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
