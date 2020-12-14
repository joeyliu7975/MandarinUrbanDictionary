//
//  RankViewController.swift
//  MandarinUrbanDictionary
//
//  Created by Joey Liu on 12/3/20.
//

import UIKit
import Charts

class RankViewController: JoeyPanelViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: RankViewModel?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        viewModel = .init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func switchSegment(_ sender: UISegmentedControl) {
        
        fetchData(at: sender.selectedSegmentIndex)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupTableView()
        
        setupNavigationController()
        
        binding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchData(at: segmentControl.selectedSegmentIndex)
        
    }
    
    func showList() {
        
        let categoryViewController = CategoryViewController()
        
        categoryViewController.delegate = self
        
        present(categoryViewController, animated: true)
    }
}

extension RankViewController: CategoryDelegate {
    
    func confirmSelection(_ selectedCategory: Category) {
       
        viewModel?.getCategory(selectedCategory)

    }
}

private extension RankViewController {
    
    func setupTableView() {
        
        tableView.registerCell(RankTableViewCell.identifierName)
        
        tableView.separatorStyle = .none
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
    }
    
    func setupNavigationController() {
        
        removeBackButtonItem()
        
        setBarAppearance(title: "Top 5")
        
        makeSideMenuButton()
        
    }
    
    func binding() {
        
        viewModel?.updateData = { [weak self] in
            
            self?.tableView.reloadData()
            
        }
        
    }
}

extension RankViewController {
    
    func fetchData(at index: Int) {
        
        switch  index {
        case 0:
            viewModel?.fetchData(sortedBy: .views)
        case 1:
            viewModel?.fetchData(sortedBy: .time)
        case 2:
            showList()
        default:
            break
        }
        
    }
    
}

extension RankViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / 5
    }
}

extension RankViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.top5WordList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: RankTableViewCell.identifierName, for: indexPath)
        
        guard let viewModel = viewModel else { return cell }
        
        let rank = viewModel.rankList[indexPath.row]
        
        let color = rank.makeColor()
        
        let word = viewModel.top5WordList[indexPath.row]
        
        if let rankCell = cell as? RankTableViewCell {
            
            rankCell.renderUI(boardColor: color, title: word)
            
            if rank == .top {
                
                rankCell.layoutSubviews()
                
                rankCell.makeCrown()
                
            }
            
            cell = rankCell
        }
        
        return cell
    }
}
