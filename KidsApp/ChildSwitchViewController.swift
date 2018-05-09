//
//  ChildSwitchViewController.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/11/11.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import UIKit
import RealmSwift
import CMPopTipView

class ChildSwitchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var childSwitchTableView: UITableView!
    @IBOutlet weak var childAddButton: UIButton!
    
    // lazy var は変数が参照されたときに { }() の中で初期化した値を使う
    lazy var cmPop: CMPopTipView = {
        
        // CMPopTipViewのメッセージ
        let v = CMPopTipView(message: "こどもを追加")!
        
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
        
        // CMPopTipViewのメッセージ
        let v = CMPopTipView(message: "なまえをタップして選択")!
        
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
    
    // childAddButtonをタップした時に CMPopTipView の表示を消す
    @IBAction func childAddButton(_ sender: Any) {
        cmPop.dismiss(animated: true)
    }
    
    // segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Segueに、UINavigationControllerを挟むとき
        // segue.destination as? UINavigationController → UIViewControllerをUINavigationControllerとして変換できる場合
        if let navC = segue.destination as? UINavigationController {
            if let childInputViewController: ChildInputViewController = navC.topViewController as? ChildInputViewController {
                let child = Child()
                
                if childArray.count != 0 {
                    child.id = childArray.max(ofProperty: "id")! + 1
                }
                
                childInputViewController.child = child
                
                // childSwitchViewControllerから遷移するので、trueとする
                childInputViewController.isFromChildSwitch = true
            }
        }
    }
    
    @IBAction func childSwitchCancelButton(_ sender: Any) {
        
        performSegue(withIdentifier: "back", sender: nil)
    }
    
    // ChildInputViewControllerから戻って来た時にchildSwitchTableViewを更新する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        childSwitchTableView.reloadData()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // UserDefaults のインスタンス
        let userDefaults = UserDefaults.standard
        
        // まだ表示したことがない（pop_childAddButton が false のとき）だけ、cmPopを表示する
        if userDefaults.bool(forKey: "pop_childAddButton") == false {
            
            // 場所を指定してCMPopTipViewを表示
            cmPop.presentPointing(at: childAddButton, in: self.view, animated: true)
            
            // 次回は表示されないように pop_childAddButton を true で保存する
            userDefaults.set(true, forKey: "pop_childAddButton")
            userDefaults.synchronize()
        }
        
        // まだ表示したことがない（pop_promise_ok が false のとき）時だけ、cmPopを表示する
        if userDefaults.bool(forKey: "pop_child_Choice") == false {
            
            // 表示されている最初のセルを取り出す
            // 1. 見えているセルの IndexPath の配列を prpmiseTableView.indexPathsForVisibleRows で取り出す
            // 2. 最初の要素を first で取り出せば、見えているセルのうち一番上の IndexPath が取り出せる
            // 3. 見えているセルうち最初の IndexPath を元にセルを取り出し、PromiseTableViewCell にキャストする
            if let indexPath = childSwitchTableView.indexPathsForVisibleRows?.first {
                if let cell = childSwitchTableView.cellForRow(at: indexPath) as? ChildSwitchTableViewCell {
                    
                    // 場所を指定してCMPopTipViewを表示
                    cmPop2.presentPointing(at: cell.childSwitchLabel, in: self.view, animated: true)
                    
                    // 次回は表示されないように pop_promise_ok を true で保存する
                    userDefaults.set(true, forKey: "pop_child_Choice")
                    userDefaults.synchronize()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
