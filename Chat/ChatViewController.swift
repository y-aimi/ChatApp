//
//  ChatViewController.swift
//  Chat
//
//  Created by 相見佳輝 on 2020/02/02.
//  Copyright © 2020 相見佳輝. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseDatabase

class ChatViewController: MessagesViewController {
    
    let user1 = MockUser(senderId: "鈴木" ,displayName: "鈴木")
    let user2 = MockUser(senderId: "佐藤" ,displayName: "佐藤")
    
    var messages:  [MockMessage] = []
    
    var ref: DatabaseReference!


    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
        
        ref = Database.database().reference()
        createFirebaseMessage()

    }
    
    func createSampleMessage(){
        //試しにチャットのやりとりを表示
        let mes1 = MockMessage(text: "鈴木です。こんにちは", user: user1,messageId: UUID().uuidString, date: Date())
        let mes2 = MockMessage(text: "どうも。佐藤です", user: user2,messageId: UUID().uuidString, date: Date())
        let mes3 = MockMessage(text: "天気が良いですね", user: user1,messageId: UUID().uuidString, date: Date())
        let mes4 = MockMessage(text: "そうですね", user: user2,messageId: UUID().uuidString, date: Date())
        
        self.messages.append(mes1)
        self.messages.append(mes2)
        self.messages.append(mes3)
        self.messages.append(mes4)
        
        self.messagesCollectionView.reloadData()
    }
        
        
    
    func createFirebaseMessage(){
        
        self.ref.observe(DataEventType.childAdded, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            //nameとmessageが空でないことをチェック
            if let name = postDict["name"] as? String,let message = postDict["message"] as? String {
                //MockUserの名前を表示
                let user = MockUser(senderId: name, displayName: name)
                //textはmessageを。userは一行上で定義したuserを。messageIdと日付は適当
                let mes = MockMessage(text: message, user: user, messageId: UUID().uuidString, date: Date())
                //messageを配列に追加
                self.messages.append(mes)
                //初期化
                self.messagesCollectionView.reloadData()
                //スクロールを一番下にしている
                self.messagesCollectionView.scrollToBottom()
            }
        })
    }
}

extension ChatViewController: MessagesDataSource {
   //自分がどのユーザーかどうかを定義化している→本来はユーザーIDを登録してもらいそれを入力
    func currentSender() -> SenderType {
        return MockUser(senderId: "佐藤", displayName: "佐藤")
    }
    //メッセージ分表示するようなコマンド
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    //セクションを定義している
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    //送信した日付や時刻を表示している
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd HH:mm"
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
       
}

    extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }

}

extension ChatViewController: MessagesDisplayDelegate {
  
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = Avatar(image: nil, initials: message.sender.displayName)
        avatarView.set(avatar: avatar)
    }
}

extension ChatViewController: MessageInputBarDelegate {

func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
    //送信するところ
    let messageData = [
        "name" : "佐藤",
        "message" : text
    ]
    self.ref.childByAutoId().setValue(messageData)

    }
}
