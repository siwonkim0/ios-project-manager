import Foundation
import RxSwift
import RxRelay

protocol ProjectRepositoryProtocol {
    func fetchData() -> BehaviorRelay<[Project]>
    func append(_ project: Project)
    func update(_ project: Project)
    func delete(_ project: Project)
}

final class ProjectRepository: ProjectRepositoryProtocol {
    let disposeBag = DisposeBag()
    let remoteDataSource = RemoteDataSource()
    let localDataSource = LocalDataSource()
    let networkConnection = NetworkChecker.shared
    private lazy var projects = BehaviorRelay<[Project]>(value: [])
    
    func fetchData() -> BehaviorRelay<[Project]> {
//        networkConnection.isConnected = false
        if networkConnection.isConnected == true {
            self.synchronize()
                .subscribe(onCompleted: {
                    self.remoteDataSource.fetch().subscribe(onSuccess: { p in
                        self.projects.accept(p)
                    })
                })
            
        } else {
            localDataSource.fetch()
                .subscribe(onSuccess: { fetchedProjects in
                self.projects.accept(fetchedProjects)
            }).disposed(by: disposeBag)
        }
        return projects
    }
    
    func synchronize() -> Completable {
        return Single.zip(localDataSource.fetch(),
                          remoteDataSource.fetch()
        ).map { localProjects, remoteProjects -> Completable in
            let localIDSet = Set(localProjects.map { $0.id })
            let remoteIDSet = Set(remoteProjects.map { $0.id })
            
            let locallyAppendedIDSet = Set(localIDSet).subtracting(Set(remoteIDSet))

            let locallyAppendedProjects = localProjects.filter {
                locallyAppendedIDSet.contains($0.id)
            }
            
            let appendCompletable = Completable.zip(locallyAppendedProjects.map {
                self.remoteDataSource.append($0)
            })
            
            let intersectingIDSet = localIDSet.intersection(remoteIDSet)
            let intersectingLocalProjects = localProjects.filter {
                intersectingIDSet.contains($0.id)
            }
            let intersectingRemoteProjects = remoteProjects.filter {
                intersectingIDSet.contains($0.id)
            }
            
            let sameIDCompletable = Completable.zip(intersectingRemoteProjects.flatMap { remoteProject in
                intersectingLocalProjects.filter { localProject in
                    localProject.id == remoteProject.id && localProject.updatedAt > remoteProject.updatedAt
                }.map { self.remoteDataSource.update($0) }
            })
            
            let deletedIDSet = remoteIDSet.subtracting(localIDSet)
            let locallyDeletedProjects = localProjects.filter {
                deletedIDSet.contains($0.id)
            }
            let deletedCompletable = Completable.zip(locallyDeletedProjects.map {
                self.remoteDataSource.delete($0)
            })
            return Completable.zip(appendCompletable, sameIDCompletable, deletedCompletable)
        }.flatMapCompletable { $0 }
        
    }
    
    func append(_ project: Project) {
        var currentProjects = projects.value
        currentProjects.append(project)
        projects.accept(currentProjects)
        
        if networkConnection.isConnected == true {
            remoteDataSource.append(project)
        }
        localDataSource.append(project)
        
    }
    
    func update(_ project: Project) {
        var currentProjects = projects.value
        if let row = currentProjects.firstIndex(where: { $0.id == project.id }) {
            currentProjects[row] = project
        }
        currentProjects.sort { $0.date > $1.date }
        projects.accept(currentProjects) //왜 completable 안써도 업데이트되지..
        
        if networkConnection.isConnected == true {
            remoteDataSource.update(project)
        }
        localDataSource.update(project)
    }
    
    func delete(_ project: Project) {
        var currentProjects = projects.value
        if let row = currentProjects.firstIndex(where: { $0.id == project.id }) {
            currentProjects.remove(at: row)
        }
        projects.accept(currentProjects)
        
        if networkConnection.isConnected == true {
            remoteDataSource.delete(project)
        }
        localDataSource.delete(project)
    }
}
