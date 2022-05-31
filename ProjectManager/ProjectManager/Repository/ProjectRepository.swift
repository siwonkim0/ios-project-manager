import Foundation
import RxSwift
import RxRelay

protocol ProjectRepositoryProtocol {
    func fetchCurrentProjects() -> [Project]
    func fetchSyncronizedData() -> BehaviorRelay<[Project]>
    func append(_ project: Project)
    func update(_ project: Project)
    func delete(_ project: Project)
}

final class ProjectRepository: ProjectRepositoryProtocol {
    let disposeBag = DisposeBag()
    let remoteDataSource: DataSourceProtocol
    let localDataSource: DataSourceProtocol
    let networkConnection = NetworkChecker.shared
    private lazy var projects = BehaviorRelay<[Project]>(value: [])
    
    init(remoteDataSource: DataSourceProtocol, localDataSource: DataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func fetchCurrentProjects() -> [Project] {
        return projects.value
    }
    
    func fetchSyncronizedData() -> BehaviorRelay<[Project]> {
        if networkConnection.isConnected == true {
            self.synchronize()
                .subscribe(onCompleted: {
                    self.remoteDataSource.fetch().subscribe(onSuccess: { projects in
                        self.projects.accept(projects)
                    }).disposed(by: self.disposeBag)
                }).disposed(by: disposeBag)
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
            
            let updateCompletable = Completable.zip(
                intersectingRemoteProjects.flatMap { remoteProject in
                    intersectingLocalProjects.filter { localProject in
                        localProject.updatedAt > remoteProject.updatedAt
                    }.map {
                        return self.remoteDataSource.update($0)
                    }
                }
            )

            let deletedIDSet = remoteIDSet.subtracting(localIDSet)
            let locallyDeletedProjects = remoteProjects.filter {
                deletedIDSet.contains($0.id)
            }
            let deleteCompletable = Completable.zip(locallyDeletedProjects.map {
                self.remoteDataSource.delete($0)
            })
            return Completable.zip(appendCompletable, updateCompletable, deleteCompletable)
        }.flatMapCompletable { $0 }
    }
    
    func append(_ project: Project) {
        if networkConnection.isConnected == true {
            Completable.zip(
                remoteDataSource.append(project),
                localDataSource.append(project)
            ).subscribe(onCompleted: { [self] in
                getUpdatedDataFromLocalDataSource()
            }).disposed(by: disposeBag)
        } else {
            localDataSource.append(project)
            .subscribe(onCompleted: { [self] in
                getUpdatedDataFromLocalDataSource()
            }).disposed(by: disposeBag)
        }
    }
    
    func update(_ project: Project) {
        if networkConnection.isConnected == true {
            Completable.zip(
                remoteDataSource.update(project),
                localDataSource.update(project))
                .subscribe(onCompleted: { [self] in
                    getUpdatedDataFromLocalDataSource()
                }).disposed(by: disposeBag)
        } else {
            localDataSource.update(project)
                .subscribe(onCompleted: { [self] in
                    getUpdatedDataFromLocalDataSource()
                }).disposed(by: disposeBag)
        }
    }
    
    func delete(_ project: Project) {
        if networkConnection.isConnected == true {
            Completable.zip(
                remoteDataSource.delete(project),
                localDataSource.delete(project)
            ).subscribe(onCompleted: { [self] in
                getUpdatedDataFromLocalDataSource()
            }).disposed(by: disposeBag)
            
        } else {
            localDataSource.delete(project)
                .subscribe(onCompleted: { [self] in
                    getUpdatedDataFromLocalDataSource()
                }).disposed(by: disposeBag)
        }
    }
    
    private func getUpdatedDataFromLocalDataSource() {
        self.localDataSource.fetch().subscribe(onSuccess: { project in
            self.projects.accept(project)
        }).disposed(by: self.disposeBag)
    }
}
