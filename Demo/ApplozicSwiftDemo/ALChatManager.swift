//
//  ALChatManager.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit
import Applozic
import ApplozicSwift

var TYPE_CLIENT : Int16 = 0
var TYPE_APPLOZIC : Int16 = 1
var TYPE_FACEBOOK : Int16 = 2

var APNS_TYPE_DEVELOPMENT : Int16 = 0
var APNS_TYPE_DISTRIBUTION : Int16 = 1

class ALChatManager: NSObject {

    static let applicationId = "applozic-sample-app"
    static let shared = ALChatManager(applicationKey: ALChatManager.applicationId as NSString)

    var pushNotificationTokenData: Data? {
        didSet {
            updateToken()
        }
    }

    init(applicationKey: NSString) {
        super.init()
        ALUserDefaultsHandler.setApplicationKey(applicationKey as String)
        self.defaultChatViewSettings()
    }

    class func isNilOrEmpty(_ string: NSString?) -> Bool {
        switch string {
            case .some(let nonNilString):
                return nonNilString.length == 0
            default:
                return true
        }
    }

    func updateToken() {
        guard let deviceToken = pushNotificationTokenData else { return }
        print("DEVICE_TOKEN_DATA :: \(deviceToken.description)")  // (SWIFT = 3) : TOKEN PARSING

        var deviceTokenString: String = ""
        for i in 0..<deviceToken.count {
            deviceTokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
        }
        print("DEVICE_TOKEN_STRING :: \(deviceTokenString)")

        if ALUserDefaultsHandler.getApnDeviceToken() != deviceTokenString {
            let alRegisterUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
            alRegisterUserClientService.updateApnDeviceToken(withCompletion: deviceTokenString, withCompletion: { (response, error) in
                print ("REGISTRATION_RESPONSE :: \(String(describing: response))")
            })
        }
    }

    // ----------------------
    // Call This at time of your app's user authentication OR User registration.
    // This will register your User at applozic server.
    //----------------------
    func connectUser(_ alUser: ALUser, completion : @escaping (_ response: ALRegistrationResponse?, _ error: NSError?) -> Void) {
        let _ = ALChatLauncher(applicationId: getApplicationKey() as String)
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        registerUserClientService.initWithCompletion(alUser, withCompletion: { (response, error) in
            guard error == nil else {
                print("Error while registering to applozic");
                let errorPass = NSError(domain:"Error while registering to applozic", code:0, userInfo:nil)
                completion(nil , errorPass as NSError?)
                return
            }
            guard let response = response, response.isRegisteredSuccessfully() else {
                ALUtilityClass.showAlertMessage("Invalid Password", andTitle: "Oops!!!")
                let errorPass = NSError(domain:"Invalid Password", code:0, userInfo:nil)
                completion(nil , errorPass as NSError?)
                return
            }
            print("Registration successfull")
            completion(response, nil)
        })
    }

    func getApplicationKey() -> NSString {
        let appKey = ALUserDefaultsHandler.getApplicationKey() as NSString?
        let applicationKey = appKey
        return applicationKey!;
    }

    func isUserPresent() -> Bool {
        guard let _ = ALUserDefaultsHandler.getApplicationKey() as String?,
            let _ = ALUserDefaultsHandler.getUserId() as String? else {
                return false
        }
        return true
    }

    func logoutUser() {
        let registerUserClientService = ALRegisterUserClientService()
        if let _ = ALUserDefaultsHandler.getDeviceKeyString() {
            registerUserClientService.logout(completionHandler: {
                _, _ in
                NSLog("Applozic logout")
            })
        }
    }

    func defaultChatViewSettings() {
        ALUserDefaultsHandler.setGoogleMapAPIKey("AIzaSyCOacEeJi-ZWLLrOtYyj3PKMTOFEG7HDlw") //REPLACE WITH YOUR GOOGLE MAPKEY
        ALApplozicSettings.setListOfViewControllers([ALKConversationListViewController.description(), ALKConversationViewController.description()])
        ALApplozicSettings.setFilterContactsStatus(true)
        ALUserDefaultsHandler.setDebugLogsRequire(true)
        ALApplozicSettings.setSwiftFramework(true)
    }

    func launchChatList(from viewController: UIViewController, with configuration: ALKConfiguration) {
        let conversationVC = ALKConversationListViewController(configuration: configuration)
        let navVC = ALKBaseNavigationViewController(rootViewController: conversationVC)
        viewController.present(navVC, animated: false, completion: nil)
    }

    func launchChatWith(contactId: String, from viewController: UIViewController, configuration: ALKConfiguration) {
        let alContactDbService = ALContactDBService()
        var title = ""
        if let alContact = alContactDbService.loadContact(byKey: "userId", value: contactId), let name = alContact.getDisplayName() {
            title = name
        }
        title = title.isEmpty ? "No name":title
        let convViewModel = ALKConversationViewModel(contactId: contactId, channelKey: nil, localizedStringFileName: configuration.localizedStringFileName)
        let conversationViewController = ALKConversationViewController(configuration: configuration)
        conversationViewController.title = title
        conversationViewController.viewModel = convViewModel
        viewController.navigationController?.pushViewController(conversationViewController, animated: false)
    }

    func launchGroupWith(clientGroupId: String, from viewController: UIViewController, configuration: ALKConfiguration) {
        let alChannelService = ALChannelService()
        alChannelService.getChannelInformation(nil, orClientChannelKey: clientGroupId) { (channel) in
            guard let channel = channel, let key = channel.key else {return}
            let convViewModel = ALKConversationViewModel(contactId: nil, channelKey: key, localizedStringFileName: configuration.localizedStringFileName)
            let conversationViewController = ALKConversationViewController(configuration: configuration)
            conversationViewController.title = channel.name
            conversationViewController.viewModel = convViewModel
            viewController.navigationController?.pushViewController(conversationViewController, animated: false)
        }
    }

    func launchChatWith(conversationProxy: ALConversationProxy, from viewController: UIViewController, configuration: ALKConfiguration) {
        let userId = conversationProxy.userId
        let groupId = conversationProxy.groupId
        let title: String = chatTitleUsing(userId: userId, groupId: groupId)
        let convViewModel = ALKConversationViewModel(contactId: userId, channelKey: groupId, conversationProxy: conversationProxy, localizedStringFileName: configuration.localizedStringFileName)
        let conversationViewController = ALKConversationViewController(configuration: configuration)
        conversationViewController.title = title
        conversationViewController.viewModel = convViewModel
        viewController.navigationController?.pushViewController(conversationViewController, animated: false)
    }

    func createAndLaunchChatWith(conversationProxy: ALConversationProxy, from viewController: UIViewController, configuration: ALKConfiguration) {
        let conversationService = ALConversationService()
        conversationService.createConversation(conversationProxy) { (error, response) in
            guard let proxy = response, error == nil else {
                print("Error creating conversation :: \(String(describing: error))")
                return
            }
            let alConversationProxy = self.conversationProxyFrom(original: conversationProxy, generated: proxy)
            self.launchChatWith(conversationProxy: alConversationProxy, from: viewController, configuration: configuration)
        }
    }

    func launchContactList(from viewController: UIViewController, configuration: ALKConfiguration) {
        let newChatVC = ALKNewChatViewController(configuration: configuration, viewModel: ALKNewChatViewModel(localizedStringFileName: configuration.localizedStringFileName))
        let navVC = UINavigationController(rootViewController: newChatVC)
        viewController.present(navVC, animated: true, completion: nil)
    }

    func setApplicationBaseUrl() {
        guard let dict = Bundle.main.infoDictionary?["APPLOZIC_PRODUCTION"] as? [AnyHashable : Any] else {
            return
        }
        /// Change URLs if they are present in the info dictionary.
        if let baseUrl = dict["AL_KBASE_URL"] as? String {
            ALUserDefaultsHandler.setBASEURL(baseUrl)
        }

        if let mqttUrl = dict["AL_MQTT_URL"] as? String {
            ALUserDefaultsHandler.setMQTTURL(mqttUrl)
        }

        if let fileUrl = dict["AL_FILE_URL"] as? String {
            ALUserDefaultsHandler.setFILEURL(fileUrl)
        }

        if let mqttPort = dict["AL_MQTT_PORT"] as? String {
            ALUserDefaultsHandler.setMQTTPort(mqttPort)
        }
    }

    /// A convenient method to get logged-in user's information.
    ///
    /// If user information is stored in DB or preference, Code to get user's information should go here.
    /// This can also be used to get existing user information in case of app update.
    /// - Returns: Logged-in user information
    func getLoggedInUserInfo() -> ALUser {
        let user = ALUser()
        user.applicationId = getApplicationKey() as String
        user.appModuleName = ALUserDefaultsHandler.getAppModuleName()
        user.userId = ALUserDefaultsHandler.getUserId()
        user.email = ALUserDefaultsHandler.getEmailId()
        user.password = ALUserDefaultsHandler.getPassword()
        user.displayName = ALUserDefaultsHandler.getDisplayName()
        return user
    }

    private func conversationProxyFrom(original: ALConversationProxy, generated: ALConversationProxy) -> ALConversationProxy{
        let finalProxy = ALConversationProxy()
        finalProxy.userId = generated.userId
        finalProxy.topicDetailJson = generated.topicDetailJson
        finalProxy.id = original.id
        finalProxy.groupId = original.groupId
        return finalProxy
    }

    private func chatTitleUsing(userId: String?, groupId: NSNumber?) -> String {
        if let contactId = userId,
            let contact = ALContactDBService().loadContact(byKey: "userId", value: contactId),
            let name = contact.getDisplayName() {
            return name
        }
        if let channelKey = groupId,
            let channel = ALChannelService().getChannelByKey(channelKey) {
            return channel.name
        }
        return "No name"
    }
}
