//
//  SettingsViewController.swift
//  SpeechBubble
//
//  Created by Diego Alejandro Villarreal López on 8/24/19.
//  Copyright © 2019 FernandoCarrillo. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var Language1: UILabel!
    @IBOutlet weak var Language2: UILabel!
    @IBOutlet weak var PickerView1: UIPickerView!
    @IBOutlet weak var PickerView2: UIPickerView!
    


    let languages = ["English", "Spanish", "German"]
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ PickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return languages[row]
    }
    func pickerView(_ PickerView1: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ PickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (PickerView == PickerView1){
            Language1.text = languages[row]
            UserDefaults.standard.set(Language1.text, forKey: "Input")
             UserDefaults.standard.set(row, forKey: "InputRow")
        }
        else
        {
            Language2.text = languages[row]
            UserDefaults.standard.set(Language2.text, forKey: "Output")
            UserDefaults.standard.set(row, forKey: "OutputRow")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       Language1.text = UserDefaults.standard.string(forKey: "Input")
        Language2.text = UserDefaults.standard.string(forKey: "Output")
        PickerView1.selectRow(UserDefaults.standard.integer(forKey: "InputRow"), inComponent: 0, animated: true)
        PickerView2.selectRow(UserDefaults.standard.integer(forKey: "OutputRow"), inComponent: 0, animated: true)
    }
        
        
        
        

        // Do any additional setup after loading the view.
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
