import Foundation
import RealmSwift
import RxSwift

class LocalDataSource {
    lazy var realm = try! Realm()
    var projectsToSyncronize = [Project]()
    let networkChecker = NetworkChecker.shared
    
    func syncronize(with project: Project) {
        let memo = ProjectRealm(project)
        if NetworkChecker.shared.isConnected == true {
            try! realm.write {
                realm.add(memo!, update: .modified)
            }
        }
    }
    
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

    func append(_ project: Project) {
        guard let memo = ProjectRealm(project) else {
            return
        }
        try! realm.write {
            realm.add(memo)
        }
    }

    func update(_ project: Project) {
        guard let memo = ProjectRealm(project) else {
            return
        }
        try! realm.write {
            memo.updatedAt = Date()
            realm.add(memo, update: .modified)
        }
    }

    func delete(_ project: Project) {
        guard let memo = realm.objects(ProjectRealm.self).filter("id = %@", project.id).first else {
            return
        }
        
        try! realm.write {
            memo.deletedAt = Date() //어짜피 삭제되어서 할필요 없긴함
            realm.delete(memo)
        }
    }
}
