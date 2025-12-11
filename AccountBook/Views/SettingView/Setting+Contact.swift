//
//  Setting+Contact.swift
//  AccountBook
//
//  Created by 김정원 on 12/11/25.
//

import MessageUI

extension SettingTableViewController: MFMailComposeViewControllerDelegate {
    func showMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            showAlertForMailNotAvailable()
            return
        }

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["garden0073@gmail.com"])    // 받을 이메일
        composer.setSubject("[가계부] 문의")    // 제목
        composer.setMessageBody(
            """
            안녕하세요.
            "가계부" 개발자 Jeongwon Kim 입니다.
            버그나 추가되었으면 하는 기능을 알려주시면 앱 개선에 반영하도록 하겠습니다.
            "가계부" 앱을 사용해주셔서 감사합니다.

            • 사용 중인 iPhone 모델: \(AppInfo.deviceModelIdentifier)
            • iOS 버전: \(AppInfo.iosVersion)
            • 앱 버전: \(AppInfo.appVersion)
            • 문의 내용:
            
            
            """,
            isHTML: false
        )

        present(composer, animated: true)
    }
    
    
    private func showAlertForMailNotAvailable() {
        let alert = UIAlertController(title: "메일 앱을 찾을 수 없습니다",
                                      message: "메일 앱이 설치되어 있지 않습니다.\ngarden0073@gmail.com 으로 직접 연락해주세요.",
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

        controller.dismiss(animated: true)

        if result == .sent {
            print("메일 전송 완료!")
        }
    }
}
