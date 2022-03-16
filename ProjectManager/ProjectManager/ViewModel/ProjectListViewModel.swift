import UIKit

protocol ProjectListViewModelProtocol: UITableViewDataSource {
    var onCellSelected: ((Int, Project) -> Void)? { get set }
    var onUpdated: (() -> Void)? { get set }
    
    func didSelectRow(indexPath: IndexPath, state: ProjectState)
    func numberOfProjects(state: ProjectState) -> Int
    func fetchAll()
    func append(_ project: Project)
    func update(_ project: Project, state: ProjectState?)
    func delete(indexPath: IndexPath, state: ProjectState)
    func changeState(from oldState: ProjectState, to newState: ProjectState, indexPath: IndexPath)
    func createEditDetailViewModel() -> EditProjectDetailViewModel
    func createAddDetailViewModel() -> AddProjectDetailViewModel
}

final class ProjectListViewModel: NSObject, ProjectListViewModelProtocol {
    let useCase: ProjectUseCaseProtocol
    var selectedProject: Project?
    
    var onCellSelected: ((Int, Project) -> Void)?
    var onUpdated: (() -> Void)?
    
    init(useCase: ProjectUseCaseProtocol) {
        self.useCase = useCase
    }
    
    private var projects: [Project] = [] {
        didSet {
            onUpdated?()
        }
    }
    
    private var todoProjects: [Project] {
        projects.filter { $0.state == .todo }
    }
    
    private var doingProjects: [Project] {
        projects.filter { $0.state == .doing }
    }
    
    private var doneProjects: [Project] {
        projects.filter { $0.state == .done }
    }
    
    private func retrieveSelectedData(indexPath: IndexPath, state: ProjectState) -> Project? {
        var selectedProject: Project?
        switch state {
        case .todo:
            selectedProject = todoProjects[indexPath.row]
        case .doing:
            selectedProject = doingProjects[indexPath.row]
        case .done:
            selectedProject = doneProjects[indexPath.row]
        }
        self.selectedProject = selectedProject
        return selectedProject
    }
    
    func didSelectRow(indexPath: IndexPath, state: ProjectState) {
        guard let selectedProject = retrieveSelectedData(indexPath: indexPath, state: state) else {
            return
        }
        onCellSelected?(indexPath.row, selectedProject)
    }
    
    func numberOfProjects(state: ProjectState) -> Int {
        switch state {
        case .todo:
            return todoProjects.count
        case .doing:
            return doingProjects.count
        case .done:
            return doneProjects.count
        }
    }
    
    func fetchAll() {
        projects = useCase.fetchAll()
    }
    
    func append(_ project: Project) {
        useCase.append(project)
        fetchAll()
    }
    
    func update(_ project: Project, state: ProjectState?) {
        useCase.update(project, to: state)
        fetchAll()
    }
    
    func delete(indexPath: IndexPath, state: ProjectState) {
        guard let project = retrieveSelectedData(indexPath: indexPath, state: state) else {
            return
        }
        useCase.delete(project)
        fetchAll()
    }
    
    func changeState(from oldState: ProjectState, to newState: ProjectState, indexPath: IndexPath) {
        guard let project = retrieveSelectedData(indexPath: indexPath, state: oldState) else {
            return
        }
        self.update(project, state: newState)
    }
    
    func createEditDetailViewModel() -> EditProjectDetailViewModel {
        let project = selectedProject ?? Project(id: UUID(), state: .todo, title: "", body: "", date: Date())
        return EditProjectDetailViewModel(currentProject: project)
    }
    
    func createAddDetailViewModel() -> AddProjectDetailViewModel {
        let project = selectedProject ?? Project(id: UUID(), state: .todo, title: "", body: "", date: Date())
        return AddProjectDetailViewModel(currentProject: project)
    }
}

extension ProjectListViewModel {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let state = (tableView as? ProjectListTableView)?.state else {
            return .zero
        }
    
        switch state {
        case .todo:
            return todoProjects.count
        case .doing:
            return doingProjects.count
        case .done:
            return doneProjects.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let state = ((tableView as? ProjectListTableView)?.state)!
        let cell = tableView.dequeueReusableCell(withClass: ProjectListTableViewCell.self)
        let project = retrieveSelectedData(indexPath: indexPath, state: state)
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        if (project?.date)! < yesterday! {
            cell.populateDataWithDate(title: project?.title ?? "", body: project?.body ?? "", date: project?.date ?? Date())
        } else {
            cell.populateData(title: project?.title ?? "", body: project?.body ?? "", date: project?.date ?? Date())
        }

        return cell
    }
}