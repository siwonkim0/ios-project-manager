import Foundation
import RealmSwift
import RxSwift

class LocalDataSource: DataSourceProtocol {
    lazy var realm = try! Realm()
    let networkChecker = NetworkChecker.shared
    
    func fetch() -> Single<[Project]> {
        var projects = [Project]()
        return Single.create { single in
            self.realm.objects(ProjectRealm.self).forEach { projectRealm in
                let project = Project(projectRealm: projectRealm)
                projects.append(project)
            }
            single(.success(projects))
            return Disposables.create()
        }
    }

    func append(_ project: Project) -> Completable {
        return Completable.create { [self] completable in
            let memo = ProjectRealm(project)
            try! self.realm.write {
                self.realm.add(memo)
            }
            completable(.completed)
            return Disposables.create()
        }
    }

    func update(_ project: Project) -> Completable {
        return Completable.create { [self] completable in
            let memo = ProjectRealm(project)
            try! self.realm.write {
                memo.updatedAt = Date()
                self.realm.add(memo, update: .modified)
            }
            completable(.completed)
            return Disposables.create()
        }
    }

    func delete(_ project: Project) -> Completable {
        return Completable.create { [self] completable in
            let memo = self.realm.objects(ProjectRealm.self).where { projectRealm in
                projectRealm.id == project.id
            }
            
            try! self.realm.write {
                self.realm.delete(memo)
            }
            completable(.completed)
            return Disposables.create()
        }
    }
}
