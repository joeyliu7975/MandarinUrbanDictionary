//
//  AddNewWordViewController.swift
//  MandarinUrbanDictionary
//
//  Created by Joey Liu on 12/1/20.
//

import UIKit

class AddNewWordViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var newWordTF: UITextField!
    
    @IBOutlet weak var definitionTextView: UITextView!
    
    @IBOutlet weak var categoryTF: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    let viewModel: AddNewWordViewModel = .init()
    
    private var pickerView: UIPickerView? {
        didSet {
            
            guard let picker = pickerView else { return }
            
            picker.delegate = self
            
            picker.dataSource = self
            
            categoryTF.inputView = picker
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
            
            view.addGestureRecognizer(tap)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        
        binding()
        
    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func clickSend(_ sender: UIButton) {
        guard
            let word = newWordTF.text,
            let definition = definitionTextView.text,
            let category = categoryTF.text
        else {
            return
        }
        
        // Can update id later after user make new word
        // Make word first , then bring Word's id to Definition
        
        var newWord = viewModel.createNewWord(word: word, definition: definition, category: category)
        
        // Call Firebase then after firebase receive result dismiss this Page
        
        self.dismiss(animated: true)
    }
}

extension AddNewWordViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        checkFormValidation()
        
    }
}

extension AddNewWordViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.becomeFirstResponder()
        
        if textView.hasPlaceholder {
            
            textView.clearText()
        }
        
        textView.setupContent(.startTyping)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        checkFormValidation()
        
    }
    
}

extension AddNewWordViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.categoryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let category = viewModel.categoryList[row].instance()
        
        return categoryTF.text = category.name
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let category = viewModel.categoryList[row].instance()
        
        return category.name
    }
}

private extension AddNewWordViewController {
    
    func setup() {
        
        newWordTF.delegate = self
        
        categoryTF.delegate = self
        
        definitionTextView.delegate = self
        
        checkFormValidation()
        
        definitionTextView.setCorner(radius: 10)
        
        definitionTextView.setupContent(.placeHolder)
        
        sendButton.setCorner(radius: 10)
        
        navigationItem.setBarAppearance(with: .separatorlineBlue)
        
        view.backgroundColor = .separatorlineBlue
        
        containerView.backgroundColor = .separatorlineBlue
        
        pickerView = UIPickerView()
    }
    
    func binding() {
        
        viewModel.updateConfirmButton = { [weak self] (isValid) in
            
            self?.sendButton.backgroundColor = isValid ? .white : .lightGray
            
            self?.sendButton.isEnabled = isValid
            
        }
        
    }
    
    func checkFormValidation() {
        
        guard
            let word = newWordTF.text,
            let definition = definitionTextView.text,
            let category = categoryTF.text,
            !word.isEmpty,
            !definition.isEmpty,
            !category.isEmpty
        else {

            viewModel.buttonIsValid = false
            
            return
        }
        
        viewModel.buttonIsValid = true
        
    }
}
