import Foundation
import RxSwift
import RxRelay

protocol ProjectRepositoryProtocol {
    func bindProjects() -> BehaviorRelay<[Project]>
    func append(_ project: Project)
    func update(_ project: Project)
    func delete(_ project: Project)
}

final class ProjectRepository: ProjectRepositoryProtocol {
    let disposeBag = DisposeBag()
    let remoteDataSource = RemoteDataSource()
    private lazy var projects = BehaviorRelay<[Project]>(value: [])
    
    func bindProjects() -> BehaviorRelay<[Project]> {
        remoteDataSource.fetch()
            .subscribe(onSuccess: { fetchedProjects in
            self.projects.accept(fetchedProjects)
        }).disposed(by: disposeBag)
        return projects
    }
    
    func append(_ project: Project) {
        var currentProjects = projects.value
        currentProjects.append(project)
        projects.accept(currentProjects)
        remoteDataSource.append(project)
    }
    
    func update(_ project: Project) {
        var currentProjects = projects.value
        if let row = currentProjects.firstIndex(where: { $0.id == project.id }) {
            currentProjects[row] = project
        }
        currentProjects.sort { $0.date > $1.date }
        projects.accept(currentProjects) //왜 completable 안써도 업데이트되지.. 이때 BehaviorRelay에 값을 전달하면 자동으로 업데이트되나
        remoteDataSource.update(project)
    }
    
    func delete(_ project: Project) {
        var currentProjects = projects.value
        if let row = currentProjects.firstIndex(where: { $0.id == project.id }) {
            currentProjects.remove(at: row)
        }
        projects.accept(currentProjects)
        remoteDataSource.delete(project)
    }
}
