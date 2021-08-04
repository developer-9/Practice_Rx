//
//  TaskListController.swift
//  GoodList
//
//  Created by Taisei Sakamoto on 2021/03/05.
//

import UIKit
import RxSwift
import RxCocoa

private let reuseIdentifier = "cell"

class TaskListController: UIViewController {
    
    //MARK: - Properties
    
    private var segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["All", "High", "Medium", "Low"])
        sc.backgroundColor = .systemBackground
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let tableView = UITableView()
    
    private var tasks = BehaviorRelay<[Task]>(value: [])
    private var filteredTasks = [Task]()
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    
    @objc func handleAddTask() {
        let controller = AddTaskController()
        
        controller.taskSubjectObservable
            .subscribe(onNext: { [unowned self] task in
                
                let priority = Priority(rawValue: segmentControl.selectedSegmentIndex - 1)
                print("DEBUG: PRIORITY IS \(priority)")
                var existingTasks = self.tasks.value
                existingTasks.append(task)
                self.tasks.accept(existingTasks)
                self.filterTasks(by: priority)
                
            }).disposed(by: disposeBag)
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    @objc func handleValueChanged() {
        let priority = Priority(rawValue: segmentControl.selectedSegmentIndex - 1)
        filterTasks(by: priority)
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Good List"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                            style: .plain, target: self,
                                                            action: #selector(handleAddTask))
        
        view.addSubview(segmentControl)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: 20).isActive = true
        segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        segmentControl.addTarget(self, action: #selector(handleValueChanged), for: .valueChanged)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.frame = CGRect(x: 0, y: 220, width: view.frame.width, height: view.frame.height)
        
        view.addSubview(tableView)
    }
    
    private func filterTasks(by priority: Priority?) {
        if priority == nil {
            self.filteredTasks = self.tasks.value
            print("DEBUG: NIL")
            self.updateTableView()
        } else {
            self.tasks.map { tasks  in
                return tasks.filter { $0.priority == priority! }
            }.subscribe(onNext: { [weak self] tasks in
                self?.filteredTasks = tasks
                print("DEBUG: TASKS ARE \(tasks)")
                self?.updateTableView()
            }).disposed(by: disposeBag)
        }
    }
    
    private func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

//MARK: - UITableViewDataSource

extension TaskListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = filteredTasks[indexPath.row].title
        return cell
    }
}

//MARK: - UITableViewDelegate

extension TaskListController: UITableViewDelegate {
    
}
