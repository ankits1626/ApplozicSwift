//
//  ALKContactListViewController.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 13/09/18.
//

import UIKit
import Applozic

open class ALKContactListViewController: ALKBaseViewController {
    
    fileprivate var viewModel: ALKContactModel
    
    fileprivate let tableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.estimatedRowHeight   = 53
        tv.rowHeight            = 53
        tv.separatorStyle       = .none
        tv.backgroundColor      = UIColor.white
        tv.keyboardDismissMode  = .onDrag
        return tv
    }()
    
    fileprivate lazy var searchBar: UISearchBar = {
        return UISearchBar.createAXSearchBar(placeholder: NSLocalizedString("SearchPlaceholder", value: SystemMessage.LabelName.SearchPlaceholder, comment: ""))
    }()
    
    required public init() {
        self.viewModel = ALKContactModel()
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.sectionIndexColor = ALKConfiguration.init().customPrimary
        // Do any additional setup after loading the view.
    }
    
    
    private func setupView() {
        title = NSLocalizedString("ContactList", value: SystemMessage.NavbarTitle.contactTitle, comment: "")
        
        //edit button
        let editButtoninBar = UIBarButtonItem(image: UIImage(named: "fill_214", in: Bundle.applozic, compatibleWith: nil), style: .plain, target: self, action: #selector(createGroup))
        navigationItem.rightBarButtonItem = editButtoninBar
        
        
        //Back button
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIcon", in: Bundle.applozic, compatibleWith: nil), style: .plain, target: self, action: #selector(customBackAction))
        navigationItem.leftBarButtonItem = leftBarButtonItem
        
        view.addViewsForAutolayout(views: [searchBar, tableView])
        setupSearchBarConstraint()
        setupTableViewConstraint()
        searchBar.delegate = self
        // Setup table view datasource/delegate
        tableView.delegate = self
        tableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false
        registerCell()
        
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    //SET UP SEARCH BAR CONSTRAINT
    private func setupSearchBarConstraint() {
        searchBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    //SET UP TABLE VIEW CONSTRAINT
    private func setupTableViewConstraint() {
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func registerCell() {
        tableView.register(ALKContactCell.self)
    }
    
    func createGroup() {
//        let newChatVC = ALKNewChatViewController(viewModel: ALKNewChatViewModel())
//        newChatVC.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(newChatVC, animated: true)
//        newChatVC.createGroupScreen()

        let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.createGroupChat, bundle: Bundle.applozic)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ALKCreateGroupViewController") as? ALKCreateGroupViewController {
            vc.setCurrentGroupSelected(groupName: "", groupProfileImg: nil, groupSelected: [ALKFriendViewModel](), delegate: self)
            vc.addContactMode = .newChat
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
//    func enableEditing(){
//        tableView.setEditing(true, animated: true)
    
//            tableView.allowsMultipleSelectionDuringEditing = true //inside setupviews
//    }

    func customBackAction(){
        tabBarController?.selectedIndex = 0
    }
}

//MARK: - UITableViewDelegate
extension ALKContactListViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let contactViewModel = viewModel.contactForRow(indexPath: indexPath, section: indexPath.section)
        let cell: ALKContactCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        cell.update(contact: contactViewModel)
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if viewModel.sectionHeaderTitle(section: section) == "*" {
            return NSLocalizedString("RegisteredContacts", value: SystemMessage.NavbarTitle.registeredContacts, comment: "")
        }else if viewModel.sectionHeaderTitle(section: section) == "_" {
            return NSLocalizedString("UnregisteredContacts", value: SystemMessage.NavbarTitle.unregisteredContacts, comment: "")
        }
        return String(viewModel.sectionHeaderTitle(section: section))
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //BACKGROUND COLOR
//        view.tintColor = UIColor.white
        
        //Title color
        if let titleView = view as? UITableViewHeaderFooterView {
            titleView.textLabel?.textColor = ALKConfiguration.init().customPrimary
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.isUserInteractionEnabled = false
        
        if self.viewModel.sectionHeaderTitle(section: indexPath.section) == "_" {
            // show popup for invitation
//            let shareApp = ShareApp()
            let message = NSLocalizedString("ShareAppMessage", value: SystemMessage.ShareApp.message, comment: "")
            let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            /* If you want to exclude certain types from sharing
             options you could add them to the excludedActivityTypes */
            //        vc.excludedActivityTypes = [UIActivityTypeMail]
            let excludeActivities = [UIActivityType.airDrop, UIActivityType.print, UIActivityType.assignToContact, UIActivityType.saveToCameraRoll, UIActivityType.addToReadingList, UIActivityType.postToFlickr, UIActivityType.postToVimeo, UIActivityType.postToFacebook, UIActivityType.message, UIActivityType.postToWeibo]
            vc.excludedActivityTypes = excludeActivities
            self.present(vc, animated: true, completion: nil)
            self.tableView.isUserInteractionEnabled = true
            return
        }
        
        let contact = self.viewModel.contactForRow(indexPath: indexPath, section: indexPath.section)
        
        let viewModel = ALKConversationViewModel(contactId: contact.userId, channelKey: nil)
        
        let conversationVC = ALKConversationViewController()
        conversationVC.viewModel = viewModel
        conversationVC.title = contact.getDisplayName()
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(conversationVC, animated: true)
        self.tableView.isUserInteractionEnabled = true
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return viewModel.sectionForSectionIndexTitle(title: title)
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return viewModel.sectionIndexTitle()
    }
}

//MARK: - UISearchBarDelegate
extension ALKContactListViewController: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filter(keyword: searchText)
        tableView.reloadData()
    }
}



//MARK: - CreateGroupChatAddFriendProtocol
extension ALKContactListViewController: ALKCreateGroupChatAddFriendProtocol {
    
    func createGroupGetFriendInGroupList(friendsSelected: [ALKFriendViewModel], groupName: String, groupImgUrl: String, friendsAdded: [ALKFriendViewModel]) {
        
        guard ALDataNetworkConnection.checkDataNetworkAvailable() else { return }
        
        //Server call
        
        let newChannel = ALChannelService()
        let membersList = NSMutableArray()
        let _ = friendsSelected.map { membersList.add($0.friendUUID as Any) }
        
        newChannel.createChannel(groupName, orClientChannelKey: nil, andMembersList: membersList, andImageLink: groupImgUrl, withCompletion: {
            channel, error in
            guard let alChannel = channel else {
                print("error creating group", error.debugDescription)
                return
            }
            print("group created")
            let message = ALMessage()
            message.groupId = alChannel.key
            let list = NSMutableArray(object: message)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadTable"), object: list)
            
            let viewModel = ALKConversationViewModel(contactId: nil, channelKey: alChannel.key)
            let conversationVC = ALKConversationViewController()
            conversationVC.viewModel = viewModel
            conversationVC.title = groupName
            self.navigationController?.pushViewController(conversationVC, animated: true)
            self.tableView.isUserInteractionEnabled = true
        })
    }
    
}