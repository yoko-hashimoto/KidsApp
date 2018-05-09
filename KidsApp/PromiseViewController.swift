//
//  PromiseViewController.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/10/13.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD
import CMPopTipView

class PromiseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var promiseTableView: UITableView!
    @IBOutlet weak var promiseAddButton: UIBarButtonItem!
    
    // lazy var は変数が参照されたときに { }() の中で初期化した値を使う
    lazy var cmPop: CMPopTipView = {
        
        // CMPopTipViewのメッセージ
        let v = CMPopTipView(message: "やくそくをクリアできたらここをタップ")!
        
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
        let v = CMPopTipView(message: "やくそくを決めよう")!
        
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
    let realm = try! Realm()
    
    // DB内のやくそくが格納されるリスト。
    // ポイント順（低い順で）ソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var promiseArray = try! Realm().objects(Promise.self).sorted(byKeyPath: "point", ascending: true).filter("FALSEPREDICATE")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // テーブルセルのタップを無効にする
        promiseTableView.allowsSelection = false
        
        promiseTableView.delegate = self
        promiseTableView.dataSource = self
        
        // カスタムした promiseTableViewCellを使えるように設定する
        let nib = UINib(nibName: "PromiseTableViewCell", bundle: nil)
        promiseTableView.register(nib, forCellReuseIdentifier: "promiseTableViewCell")
        
        // セルの高さはAutoLayoutに任せる
        promiseTableView.rowHeight = UITableViewAutomaticDimension
        
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
        return promiseArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な　cell を得る　(cellをカスタムした　promiseTableViewCell　として扱う)
        let cell = tableView.dequeueReusableCell(withIdentifier: "promiseTableViewCell", for: indexPath) as! PromiseTableViewCell
        
        // promiseTableViewCellに値を設定する
        let promise = promiseArray[indexPath.row]
        // やくそくの内容を表示する
        cell.promiseLabel?.text = promise.promisecontents
        // やくそくのポイントを表示する
        cell.promisePointLabel?.text =  "\(promise.point)P"
        // 約束が実行された回数を表示する
        cell.promiseCountLabel?.text = "\(promise.count)"
        
         //編集中の場合はOKボタンを無効化
        if self.promiseTableView.isEditing {
            cell.okButton.isEnabled = false
            
        // 編集中でない場合はOKボタンを有効化
        } else {
            cell.okButton.isEnabled = true
        }
        
        // セルの中のOKボタンをタップすると handleOkButton のメソッドが呼ばれる。ボタンをタップして指を話した時に。
        cell.okButton.addTarget(self, action: #selector(handleOkButton(sender:event:)), for: UIControlEvents.touchUpInside)
        
        // セルの中のOKボタンタップ時にハイライトさせるかどうかの設定
        cell.okButton.showsTouchWhenHighlighted = true
        
        // セルの中のOKボタンタップ時にハイライトさせる設定を取得
        let _ : Bool = cell.okButton.showsTouchWhenHighlighted
        
        // セルの中のOKボタンを角丸にする
        cell.okButton.layer.cornerRadius = 10
        
        return cell
    }
    
    // セルの中のOKボタンがタップされた時に呼ばれるメソッド
    func handleOkButton(sender: UIButton, event:UIEvent) {
        
        // アラートコントローラーを使って、ポイント追加の確認画面を表示する
        // ① アラートコントローラーの実装
        let alertController = UIAlertController(title: "やくそく",message: "ポイントを追加しますか？", preferredStyle: UIAlertControllerStyle.alert)
        
        // ②-1 アラートコントローラーのOKボタンの実装
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default){ (action: UIAlertAction) in
            
        // ②-2 アラートコントローラーのOKボタンがタップされた時の処理
        // タップされたボタンのセルのインデックス(場所)を求める　→　どのやくそくか
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.promiseTableView)
        let indexPath = self.promiseTableView.indexPathForRow(at: point)
        
        // promiseArray からタップされたインデックスのやくそくを取り出す
        let promiseData = self.promiseArray[indexPath!.row]
        
        // Realm の書き込みのメソッドを使って count に実行されたやくそくの数を足す
        try! self.realm.write {
            promiseData.count += 1
        }
        
        // CMPopTipView の表示を消す
        self.cmPop.dismiss(animated: true)
        
        // tableViewを更新してラベルの表示を変える
        self.promiseTableView.reloadData()
        
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
        performSegue(withIdentifier: "promiseSegue", sender: nil)
    }

    // セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Editボタンが押された時に呼ばれるメソッド
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        promiseTableView.setEditing(editing, animated: animated)
        
        // promiseTableViewを更新し、セルの中のOKボタンのisEnabledを切り替える(編集中なので、無効にする)
        promiseTableView.reloadData()
    }
    
    // 削除可能なセルの indexpath を指定する (全てのCellを削除可能ととする)
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // indexPath を使って、その行のやくそくを取得する
            let promise = promiseArray[indexPath.row]
            
            // promise.count が 0 ではない時(計算済の時）
            if promise.count != 0 {
            
            // Realmの書き込みメソッドを使って、そのやくそくを削除済みにする(deletedをtrueにする)
                try! realm.write {
                    promise.deleted = true
                    
                    // promiseTableView の「表示」(見た目)から該当のセルをアニメーション付きで削除する
                    promiseTableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
                }
                
                // promise.count が 0 の時(まだ計算してない時）は実際に削除する
            } else {
                try! realm.write {
                    // データを削除する
                    self.realm.delete(promiseArray[indexPath.row])
                    
                    // promiseTableView の「表示」（見た目）から該当のセルをアニメーション付きで削除する
                    promiseTableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
                    
                }
            }
        }
    }
    
    // segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let promiseInputViewController:PromiseInputViewController = segue.destination as! PromiseInputViewController
        
        // segueのIdentifierがpromiseSegue(セルをタップした)の時
        if segue.identifier == "promiseSegue" {
            let indexPath = self.promiseTableView.indexPathForSelectedRow
            promiseInputViewController.promise = promiseArray[indexPath!.row]
        
            // セルをタップした時は編集なので isNewPromise は falseとする
            promiseInputViewController.isNewPromise = false
            
            // +ボタンをタップした時
        } else {
            let promise = Promise()
            
            // 子供ごとではなく全ての約束を取得する
            let allPromises = realm.objects(Promise.self)
            if allPromises.count != 0 {
                // すでに存在しているやくそくのidの内、最大のものを取得し、1を足すことで他のidと重ならない値を指定する
                promise.id = allPromises.max(ofProperty: "id")! + 1
            }
            
            promiseInputViewController.promise = promise
            
            // ＋ボタンをタップした時は新規登録なので isNewPromise は true とする
            promiseInputViewController.isNewPromise = true
            
            // CMPopTipViewの表示を消す
            cmPop2.dismiss(animated: true)
            
        }
    }
    
    // 入力画面から戻ってきた時にPromiseTableViewを更新させる
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
                
                // こどもが持っている(こどもに属している)やくそくをポイントの低い順 (昇順)にソートし、未削除(削除ボタンを押していない物)のみ取り出す
                promiseArray = child.promises.sorted(byKeyPath: "point", ascending: true).filter("deleted = false")
                
                // promiseTableViewを更新する
                promiseTableView.reloadData()
                
                // navigationBarにタイトルをセットする
                self.navigationItem .title = child.name
                
                // フォントをサイズを22に指定
                self.navigationController?.navigationBar.titleTextAttributes
                    = [NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 22)!]
                
                // こどもが選択されていなければアラートを出す
            } else {
                SVProgressHUD.showError(withStatus: "こどもを選択してください")
                
                // promiseTableViewを更新する
                promiseTableView.reloadData()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // UserDefaults のインスタンス
        let userDefaults = UserDefaults.standard
        
        // まだ表示したことがない（pop_promise_ok が false のとき）時だけ、cmPopを表示する
        if userDefaults.bool(forKey: "pop_promise_ok") == false {
            
            // 表示されている最初のセルを取り出す
            // 1. 見えているセルの IndexPath の配列を prpmiseTableView.indexPathsForVisibleRows で取り出す
            // 2. 最初の要素を first で取り出せば、見えているセルのうち一番上の IndexPath が取り出せる
            // 3. 見えているセルうち最初の IndexPath を元にセルを取り出し、PromiseTableViewCell にキャストする
            if let indexPath = promiseTableView.indexPathsForVisibleRows?.first {
                if let cell = promiseTableView.cellForRow(at: indexPath) as? PromiseTableViewCell {
                    
                    // 場所を指定してCMPopTipViewを表示
                    cmPop.presentPointing(at: cell.okButton, in: self.view, animated: true)
                    
                    // 次回は表示されないように pop_promise_ok を true で保存する
                    userDefaults.set(true, forKey: "pop_promise_ok")
                    userDefaults.synchronize()
                }
            }
        }
        
        // まだ表示したことがない（pop_promise_addが false のとき）時だけ、cmPopを表示する
        if userDefaults.bool(forKey: "pop_promise_add") == false {
    
            // 場所を指定してCMPopTipViewを表示
            cmPop2.presentPointing(at: promiseAddButton, animated: true)
            
            // 次回は表示されないように pop_promise_add を true で保存する
            userDefaults.set(true, forKey: "pop_promise_add")
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
