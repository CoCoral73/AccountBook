//
//  CategoryEditViewController.swift
//  AccountBook
//
//  Created by 김정원 on 9/17/25.
//

import UIKit

class CategoryEditViewController: UIViewController {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var iconTextField: UIEmojiTextField!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var removeButton: UIButton!
    
    var viewModel: CategoryEditViewModel
    var presentationStyle: PresentationStyle = .modal
    
    required init?(coder: NSCoder, viewModel: CategoryEditViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureNavigationBar()
        configureTextField()
        configureTapGesture()
    }
    
    func configureUI() {
        iconTextField.text = viewModel.textForIcon
        iconImageView.image = viewModel.textForIcon.toImage()
        nameTextField.text = viewModel.nameString
        removeButton.isHidden = viewModel.isHiddenForRemoveButton
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navItem.standardAppearance = appearance
        
        navItem.title = viewModel.title
    }
   
    func configureTextField() {
        iconTextField.delegate = self
        nameTextField.delegate = self
        
        let accessoryLabel = UILabel()
        accessoryLabel.text = "아이콘 입력 중... 이모지를 선택하세요"
        accessoryLabel.textAlignment = .center
        accessoryLabel.backgroundColor = .secondarySystemBackground
        accessoryLabel.frame.size.height = 44
        iconTextField.inputAccessoryView = accessoryLabel
    }
    
    func configureTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        iconImageView.addGestureRecognizer(tap)
    }
    
    @objc func handleTapGesture() {
        iconTextField.becomeFirstResponder()
    }
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        close()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        let icon = iconTextField.text, name = nameTextField.text
        if let error = viewModel.validateInput(icon: icon, name: name) {
            view.endEditing(true)
            HapticFeedback.notify(.error)
            ToastManager.shared.show(message: error.message, in: view)
            return
        }
        
        viewModel.handleDoneButton(icon: icon!, name: name!)
        close()
    }
    
    @IBAction func removeButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        let alert = UIAlertController(title: "삭제", message: "해당 카테고리를 삭제하시겠습니까?", preferredStyle: .alert)

        let success = UIAlertAction(title: "삭제", style: .destructive) { action in
            self.viewModel.handleRemoveButton()
            self.close()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)

        alert.addAction(success)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
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

extension CategoryEditViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == iconTextField {
            if string.count == 1, let char = string.first, char.isEmoji {
                textField.text = string   // 마지막 이모지만 유지
                iconImageView.image = textField.text?.toImage()
            } else {
                textField.text = ""
                iconImageView.image = UIImage(systemName: "photo.circle")
            }
            
            return false
        } else {
            if (textField.text ?? "") == "", let first = string.first, first.isWhitespace {
                return false
            }
            return true
        }
    }
    
}
