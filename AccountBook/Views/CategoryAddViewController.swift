//
//  CategoryAddViewController.swift
//  AccountBook
//
//  Created by 김정원 on 9/17/25.
//

import UIKit

class CategoryAddViewController: UIViewController {

    @IBOutlet weak var iconTextField: UIEmojiTextField!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    
    var viewModel: CategoryAddViewModel
    var presentationStyle: PresentationStyle = .modal
    
    required init?(coder: NSCoder, viewModel: CategoryAddViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        configureTextField()
    }
    
    func configure() {
        navigationItem.title = viewModel.title
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        iconImageView.addGestureRecognizer(tap)
        
        iconImageView.image = viewModel.textForIcon.toImage()
    }
   
    func configureTextField() {
        iconTextField.delegate = self
        nameTextField.delegate = self
        
        iconTextField.text = viewModel.textForIcon
        
        let accessoryLabel = UILabel()
        accessoryLabel.text = "아이콘 입력 중... 이모지를 선택하세요"
        accessoryLabel.textAlignment = .center
        accessoryLabel.backgroundColor = .secondarySystemBackground
        accessoryLabel.frame.size.height = 44
        iconTextField.inputAccessoryView = accessoryLabel
    }
    
    @objc func handleTapGesture() {
        iconTextField.becomeFirstResponder()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        close()
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let icon = iconTextField.text, name = nameTextField.text
        guard viewModel.validateInput(icon: icon, name: name) == nil else {
            view.endEditing(true)
            HapticFeedback.notify(.error)
            ToastManager.shared.show(message: "아이콘과 이름을 입력해주세요.", in: view)
            return
        }
        
        viewModel.handleAddButton(icon: icon!, name: name!)
        close()
    }
    
    func close() {
        switch presentationStyle {
        case .modal:
            dismiss(animated: true)
        case .push:
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        iconTextField.becomeFirstResponder()
    }
}

extension CategoryAddViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == iconTextField {
            if string.count == 1, let char = string.first, char.isEmoji {
                textField.text = string   // 마지막 이모지만 유지
            } else {
                textField.text = ""
            }
            
            iconImageView.image = textField.text?.toImage()
            return false
        } else {
            if (textField.text ?? "") == "", let first = string.first, first.isWhitespace {
                return false
            }
            return true
        }
    }
    
}
