//
//  ChildInputViewController.swift
//  KidsApp
//
//  Created by 橋本養子 on 2017/10/13.
//  Copyright © 2017年 kotokotokoto. All rights reserved.
//

import UIKit
import RealmSwift

class ChildInputViewController: UIViewController {
    
    @IBOutlet weak var childTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    @IBAction func childSaveButton(_ sender: Any) {
        
        try! realm .write {
            self.child.name = self.childTextField.text!
            self.realm.add(self.child, update: true)
        }
        
        // 画面を閉じる(navigationControllerを挟んでいる場合)
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func childCancelButton(_ sender: Any) {
        
        // 画面を閉じる(navigationControllerを挟んでいる場合)
        navigationController?.popViewController(animated: true)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func dismissKeyboard() {
        //キーボードを閉じる
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
