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
    private let disposeBag = DisposeBag()
    private let remoteDataSource: DataSourceProtocol
    
    private lazy var projects = BehaviorRelay<[Project]>(value: [])
    
    init(remoteDataSource: DataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
    }
    
    func bindProjects() -> BehaviorRelay<[Project]> {
        remoteDataSource.fetch()
            .subscribe(onSuccess: { [weak self] event in
                self?.projects.accept(event)
            }).disposed(by: disposeBag)
        return projects
    }
    
    func append(_ project: Project) {
        remoteDataSource.append(project)
            .subscribe(onCompleted: { [weak projects] in
                var currentProjects = projects?.value
                currentProjects?.append(project)
                projects?.accept(currentProjects ?? [])
            }).disposed(by: disposeBag)
    }
    
    func update(_ project: Project) {
        remoteDataSource.update(project)
            .subscribe(onCompleted: { [weak projects] in
                guard var currentProjects = projects?.value,
                      let index = currentProjects.firstIndex(of: project) else {
                    return
                }
                currentProjects[index] = project
                
                projects?.accept(currentProjects)
            }).disposed(by: disposeBag)
    }
    
    func delete(_ project: Project) {
        remoteDataSource.delete(project)
            .subscribe(onCompleted: { [weak projects] in
                guard var currentProjects = projects?.value,
                      let index = currentProjects.firstIndex(of: project) else {
                    return
                }
                currentProjects.remove(at: index)
                
                projects?.accept(currentProjects)
            }).disposed(by: disposeBag)
    }
}
