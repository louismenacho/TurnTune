//
//  CodeEntryView.swift
//  TurnTune
//
//  Created by Louis Menacho on 8/8/21.
//

import UIKit

class CodeEntryView: UIStackView {

    @IBOutlet var textFields: [UITextField]!
    
    var code: String {
        textFields.compactMap { $0.text }.joined()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textFields.forEach {
            $0.delegate = self
        }
    }
}

extension CodeEntryView: UITextFieldDelegate {
 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.count <= 1 else {
            return false
        }
        
        print("string:\(string)")
        
        if let index = textFields.firstIndex(of: textField) {
            
            if string.count == 1 && index+1 < 4 {
                textFields[index+1].becomeFirstResponder()
            }
            
            if string.count == 1 && index == 3 {
                textField.endEditing(true)
            }

            if string.count == 0 && index-1 >= 0 {
                textFields[index-1].becomeFirstResponder()
            }
        }
        
        textField.text = string
        return false
    }
    
}
