//
//  GRPickerViewController.swift
//  Example
//
//  Created by Gaurav Parmar on 01/05/21.
//

import UIKit

/// Image styles
public enum ImageStyle {
    
    // Corner style will be applied
    case corner
    
    // Circular style will be applied
    case circular
    
    // Rectangle style will be applied
    case normal
}

open class GRPickerViewController: UIViewController {
    
    // MARK: - UI Metrics
    struct UI {
        static let rowHeight = CGFloat(50)
        static let separatorColor: UIColor = UIColor.lightGray.withAlphaComponent(0.4)
    }
    
    // MARK: - Type of Controller
    public enum PickerType {
        case country
        case phoneCode
        case currency
    }
    
    
    internal var searchController = UISearchController(searchResultsController: nil)
    internal let tableView =  UITableView()
    
    fileprivate var type: PickerType
    fileprivate var safeArea: UILayoutGuide!
    
    fileprivate var orderedInfo = [String: [DataInfo]]()
    fileprivate var sortedInfoKeys = [String]()
    fileprivate var filteredInfo: [DataInfo] = []
    fileprivate var selectedInfo: DataInfo?
    
    // MARK: - Publice Variables
    public var statusBarStyle: UIStatusBarStyle? = .default
    public var isStatusBarVisible = true
    public var delegate : GRPickerDelegate?
    
    public var imgStyle: ImageStyle = .normal {
        didSet { self.tableView.reloadData() }
    }
    
    public var labelFont: UIFont = UIFont.preferredFont(forTextStyle: .title3) {
        didSet { self.tableView.reloadData() }
    }
    
    public var labelColor: UIColor = UIColor.black {
        didSet { self.tableView.reloadData() }
    }
    
    public var detailFont: UIFont = UIFont.preferredFont(forTextStyle: .subheadline) {
        didSet { self.tableView.reloadData() }
    }
    
    public var detailColor: UIColor = UIColor.lightGray {
        didSet { self.tableView.reloadData() }
    }
    
    public var separatorLineColor: UIColor = UIColor.lightGray.withAlphaComponent(0.4) {
        didSet { self.tableView.reloadData() }
    }
    
    public var isImageHidden: Bool = false {
        didSet { self.tableView.reloadData() }
    }
    
    public var screenTite : String = "Select Country" {
        didSet { self.title = screenTite }
    }
    
    
    // MARK: - Initialize
    required public init(type: PickerType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        let _ = searchController.view
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        safeArea = view.layoutMarginsGuide
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        // Setup view bar buttons
        let uiBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                     target: self,
                                                     action: #selector(self.crossButtonClicked(_:)))
               
        self.navigationItem.leftBarButtonItem = uiBarButtonItem
        
        self.setUpTableView()
        self.setUpSearchController()
        self.getLocalData()
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets.zero
        tableView.rowHeight = UI.rowHeight
        tableView.separatorColor = UI.separatorColor
        tableView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        self.registerCell()
    }
    
    private func setUpSearchController() {
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.barStyle = .default
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }
        
        definesPresentationContext = true
    }
    
    private func registerCell() {
        switch type {
        case .country:
            tableView.register(CountryTableViewCell.self, forCellReuseIdentifier: CountryTableViewCell.identifier)
        case .phoneCode:
            tableView.register(PhoneCodeTableViewCell.self, forCellReuseIdentifier: PhoneCodeTableViewCell.identifier)
        case .currency:
            tableView.register(CurrencyTableViewCell.self, forCellReuseIdentifier: CurrencyTableViewCell.identifier)
        }
    }
    
    private func getLocalData() {
        
        LocalData.fetch { [unowned self] result in
            switch result {
            
            case .success(let orderedInfo):
                let data: [String: [DataInfo]] = orderedInfo
                self.orderedInfo = data
                self.sortedInfoKeys = Array(self.orderedInfo.keys).sorted(by: <)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .error(let error):
                print(error.message ?? "")
            }
        }
    }
    
    fileprivate func info(at indexPath: IndexPath) -> DataInfo? {
        if searchController.isActive {
            return filteredInfo.count > 0 ? filteredInfo[indexPath.row] : nil
        }
        let key: String = sortedInfoKeys[indexPath.section]
        if let info = orderedInfo[key]?[indexPath.row] {
            return info
        }
        return nil
    }
    
    fileprivate func indexPathOfSelectedInfo() -> IndexPath? {
        guard let selectedInfo = selectedInfo else { return nil }
        if searchController.isActive {
            for row in 0 ..< filteredInfo.count {
                if filteredInfo[row].country == selectedInfo.country {
                    return IndexPath(row: row, section: 0)
                }
            }
        }
        for section in 0 ..< sortedInfoKeys.count {
            if let orderedInfo = orderedInfo[sortedInfoKeys[section]] {
                for row in 0 ..< orderedInfo.count {
                    if orderedInfo[row].country == selectedInfo.country {
                        return IndexPath(row: row, section: section)
                    }
                }
            }
        }
        return nil
    }
    
    fileprivate func sortFilteredInfo() {
        filteredInfo = filteredInfo.sorted { lhs, rhs in
            switch type {
            case .country:
                return lhs.country < rhs.country
            case .phoneCode:
                return lhs.country < rhs.country
            case .currency:
                return lhs.country < rhs.country
            }
        }
    }
    
    // MARK: - Cross Button Action
    @objc private func crossButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.delegate?.didClose(self)
        }
    }
}

extension GRPickerViewController : UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive { return 1 }
        return sortedInfoKeys.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive { return filteredInfo.count }
        if let infoForSection = orderedInfo[sortedInfoKeys[section]] {
            return infoForSection.count
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if searchController.isActive { return 0 }
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: .top , animated: false)
        return sortedInfoKeys.firstIndex(of: title)!
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive { return nil }
        return sortedInfoKeys
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive { return nil }
        return sortedInfoKeys[section]
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let info = info(at: indexPath) else { return UITableViewCell() }
        
        let cell: UITableViewCell
        
        switch type {
        
        case .country:
            cell = tableView.dequeueReusableCell(withIdentifier: CountryTableViewCell.identifier) as! CountryTableViewCell
            cell.textLabel?.text = info.country
            
        case .phoneCode:
            cell = tableView.dequeueReusableCell(withIdentifier: PhoneCodeTableViewCell.identifier) as! PhoneCodeTableViewCell
            cell.textLabel?.text = info.phoneCode
            cell.detailTextLabel?.text = info.country
            
        case .currency:
            cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.identifier) as! CurrencyTableViewCell
            cell.textLabel?.text = info.currencyCode
            cell.detailTextLabel?.text = info.country
        }
        
        cell.textLabel?.font = labelFont
        cell.textLabel?.textColor = labelColor
        
        cell.detailTextLabel?.font = detailFont
        cell.detailTextLabel?.textColor = labelColor
        
        if !isImageHidden {
            var img : UIImage?
            
            if imgStyle == .normal {
                let size: CGSize = CGSize(width: 32, height: 24)
                img = info.flag?.imageWithSize(size: size, roundedRadius: 0)
            }else if imgStyle == .corner {
                let size: CGSize = CGSize(width: 32, height: 24)
                img = info.flag?.imageWithSize(size: size, roundedRadius: 3)
            }else if imgStyle == .circular {
                let size: CGSize = CGSize(width: 30, height: 30)
                img = info.flag?.imageWithSize(size: size, roundedRadius: 15)
            }
            
            cell.imageView?.image = img
        }else {
            cell.imageView?.isHidden = true
        }
        
        
        
        if let selected = selectedInfo, selected.country == info.country {
            cell.isSelected = true
        }
        
        return cell
    }
}
extension GRPickerViewController : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let info = info(at: indexPath) else { return }
        selectedInfo = info
        self.dismiss(animated: true) {
            self.delegate?.didSelected(self, with: self.selectedInfo)
        }
    }
}
extension GRPickerViewController : UISearchResultsUpdating {
    
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchController.isActive {
            filteredInfo = []
            if searchText.count > 0, let values = orderedInfo[String(searchText[searchText.startIndex])] {
                filteredInfo.append(contentsOf: values.filter { $0.country.hasPrefix(searchText) })
            } else {
                orderedInfo.forEach { key, value in
                    filteredInfo += value
                }
            }
            sortFilteredInfo()
        }
        tableView.reloadData()
        
        guard let selectedIndexPath = indexPathOfSelectedInfo() else { return }
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
    }
}
// MARK: - UISearchBarDelegate

extension GRPickerViewController: UISearchBarDelegate {
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
