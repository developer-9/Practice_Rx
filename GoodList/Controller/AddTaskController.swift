//
//  AddTaskController.swift
//  GoodList
//
//  Created by Taisei Sakamoto on 2021/03/05.
//

import UIKit
import RxSwift

class AddTaskController: UIViewController {
    
    //MARK: - Properties
    
    private let taskSubject = PublishSubject<Task>()
    
    var taskSubjectObservable: Observable<Task> {
        return taskSubject.asObserver()
    }
    
    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["High", "Medium", "Low"])
        sc.backgroundColor = .systemBackground
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let inputTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .systemGroupedBackground
        tf.layer.cornerRadius = 5
        return tf
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    
    @objc func handleSave() {
        guard let priority = Priority(rawValue: self.segmentControl.selectedSegmentIndex),
              let title = self.inputTextField.text else { return }
        
        let task = Task(title: title, priority: priority)
        taskSubject.onNext(task)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Add Task"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
        
        view.addSubview(segmentControl)
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                            constant: 20).isActive = true
        segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(inputTextField)
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputTextField.widthAnchor.constraint(equalToConstant: 200).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
}
