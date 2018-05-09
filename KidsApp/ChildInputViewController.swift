//
//  ChildInputViewController.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/10/13.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD

class ChildInputViewController: UIViewController {
    
    @IBOutlet weak var childTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // ChildSwotchViewControllerから遷移して来たか、ChildViewControllerから遷移して来たどうか、判別する為のプロパティ
    var isFromChildSwitch = false
    
    // 自作の関数
    func close() {
        // ChildSwitchViewControllerから遷移した場合
        if navigationController?.viewControllers.first is ChildViewController {
            
            // 画面を閉じる(navigationControllerを挟んでいる場合(ChildSwitchViewControllerから遷移している時))
            navigationController?.popViewController(animated: true)
            
            // 画面を閉じる(直接Segueで遷移して来ている時(ChildViewControllerから遷移している時))
        } else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func childSaveButton(_ sender: Any) {
        
        // データを記録する
        try! realm .write {
            
            // childTextFieldが空欄の時はモーダルでエラーを表示させる
            if (childTextField.text?.isEmpty)! {
                SVProgressHUD.showError(withStatus: "名前を入力して下さい")
                return
                
            } else {
            self.child.name = self.childTextField.text!
            }
            
            self.realm.add(self.child, update: true)
        }
        
        close()
    }
    
    
    @IBAction func childCancelButton(_ sender: Any) {
        
        close()
    }
    
    var child: Child!
    let realm = try!Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        childTextField.text = child.name
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 保存ボタンを角丸にする
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
        
        // キャンセルボタンを角丸にする
        cancelButton.layer.cornerRadius = 10
        cancelButton.clipsToBounds = true
        
        // childSwitchViewControllerから遷移してきた場合
        if isFromChildSwitch {
        
            // ×ボタンを作成。
            let stopButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(clickStopButton))
            
        //ナビゲーションバーの左側にボタンを配置
        self.navigationItem.setLeftBarButtonItems([stopButton], animated: true)
            
            // ナビゲーションバー上のアイテムの色をピンクに設定する
            let pinkColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 128.0/255.0, alpha:1)
            self.navigationController?.navigationBar.tintColor = pinkColor
        }
    }
    
    //stopButtonを押した際の処理 → 画面を閉じる 
    func clickStopButton(){
        
        close()
    }
    
    func dismissKeyboard() {
        //キーボードを閉じる
        view.endEditing(true)
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
