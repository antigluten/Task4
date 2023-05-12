//
//  ViewController.swift
//  Task4
//
//  Created by va-gusev on 11.05.2023.
//

import UIKit

class ViewController: UIViewController {

    struct Item: Hashable, Equatable {
        let number: Int
        var isChecked: Bool
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            return lhs.number == rhs.number
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(number)
        }
    }

    enum Section {
        case main
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Item> = {
        return .init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self))
            
            var configuration = UIListContentConfiguration.cell()
            configuration.text = "\(itemIdentifier.number)"
            cell?.contentConfiguration = configuration
            
            return cell
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        tableView.delegate = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        loadInitialSnapshot()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shuffle", style: .plain, target: self, action: #selector(shuffle))
    }
    
    func loadInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])

        let items = Array(0...30).map { Item(number: $0, isChecked: false) }
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot)
        tableView.dataSource = dataSource
    }

    @objc func shuffle() {
        var snp = dataSource.snapshot()
        let items = snp.itemIdentifiers.shuffled()

        snp.deleteItems(items)
        snp.appendItems(items, toSection: .main)
        dataSource.apply(snp, animatingDifferences: true)
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var snp = dataSource.snapshot()
        var items = snp.itemIdentifiers(inSection: .main)
        let shouldMove = !items[indexPath.row].isChecked
        
        items[indexPath.row].isChecked.toggle()
        
        snp.deleteAllItems()
        snp.appendSections([.main])
        snp.appendItems(items, toSection: .main)
        
        tableView.cellForRow(at: indexPath)?.accessoryType = items[indexPath.row].isChecked ? .checkmark : .none
        
        if indexPath.row > 0 && shouldMove {
            snp.moveItem(items[indexPath.row], beforeItem: items[0])
        }
        
        dataSource.apply(snp, animatingDifferences: true)
    }
}


