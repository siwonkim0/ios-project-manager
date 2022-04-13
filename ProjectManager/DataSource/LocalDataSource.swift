import Foundation
import RealmSwift
import RxSwift

class LocalDataSource {
    lazy var realm = try! Realm()
    
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
            self.realm.objects(ProjectRealm.self).forEach { project in
                let new = Project(id: project.id,
                        state: ProjectState(rawValue: project.state)!,
                        title: project.title,
                        body: project.body,
                        date: project.date)
                projects.append(new)
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
            realm.add(memo, update: .modified)
        }
    }

    func delete(_ project: Project) {
        try! realm.write {
            let memo = realm.object(ofType: ProjectRealm.self, forPrimaryKey: "\(project.id)")
            realm.delete(memo!)
        }
    }
}
