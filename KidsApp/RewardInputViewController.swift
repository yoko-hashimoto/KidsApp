//
//  RewardInputViewController.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/10/13.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD

class RewardInputViewController: UIViewController {
    
    @IBOutlet weak var rewardTextField: UITextField!
    @IBOutlet weak var rewardPointTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    // 入力するごほうびが新規か編集中かを判別する為のプロパティ
    var isNewReward = false
    
    @IBAction func rewardSaveButton(_ sender: Any) {
        
        // データを記録する
        try! realm.write {
            self.reward.rewardcontents = self.rewardTextField.text!
            
            // rewardPointTextFieldに表示されている文字列をInt型に変換する
            if let rewardPoint = Int (self.rewardPointTextField.text!) {
                self.reward.point = rewardPoint
                
                // Int型に変換できなかった時はモーダルでエラー表示をさせる
            } else {
                
                SVProgressHUD.showError(withStatus: "数字を入力して下さい")
            }
            
            
            // UserDefaults のインスタンス
            let userDefaults = UserDefaults.standard
            
            // childIDが保存されていてたら（子供が選択されていたら）Keyを指定して読み込み(Int型で取り出す)
            if let childId: Int = userDefaults.integer(forKey: "child") {
                
                // UserDefaultsに保存されている child.id を元に、選択中の子供を取り出す
                let predicate = NSPredicate(format: "id == %d", childId)
                let children = try!Realm().objects(Child.self).filter(predicate)
                
                // childrenは配列なので、その中から最初の子供を取り出し、以下の内容を実行する
                if let child = children.first {
                    
                    // isNewReward が flase の時
                    if isNewReward {
                        
                        // UserDefaultsに保存されているに子供にごほうびをを追加する
                        child.rewards.append(reward)
                        
                        // ごほうびを登録する時点では完了していないので　finished は　false とする
                        reward.finished = false
                    }
                }
            }
            
            
            self.realm.add(self.reward, update: true)
        }
        
        // 画面を閉じる(navigationControllerを挟んでいる場合)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func rewardCancelButton(_ sender: Any) {
        
        // 画面を閉じる(navigationControllerを挟んでいる場合)        
        navigationController?.popViewController(animated: true)
    }
    
    var reward: Reward!
    let realm = try!Realm()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // ごほうびの内容を表示させる
        rewardTextField.text = reward.rewardcontents
        
        // ごほうびポイントが0じゃない時は表示させる
        if reward.point != 0 {
            rewardPointTextField.text = "\(reward.point)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    
    func dismissKeyboard() {
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 保存ボタンを角丸にする
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
        
        // キャンセルボタンを角丸にする
        cancelButton.layer.cornerRadius = 10
        cancelButton.clipsToBounds = true
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
