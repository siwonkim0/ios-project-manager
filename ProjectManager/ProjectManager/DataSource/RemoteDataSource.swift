import Foundation
import RxSwift
import FirebaseFirestore

class RemoteDataSource: DataSourceProtocol {
    let dataBase = Firestore.firestore()
    
    func fetch() -> Single<[Project]> {
        return Single.create { single in
            self.dataBase
                .collection("users")
                .getDocuments { snapshot, error in
                if let snapshot = snapshot, error == nil {
                    let projects = snapshot.documents.compactMap { document in
                        Project(document: document.data())
                    }
                    single(.success(projects))
                }
            }
            return Disposables.create()
        }
    }
    
    func append(_ project: Project) -> Completable {
        return Completable.create { completable in
            self.dataBase
                .collection("users")
                .document(project.id.description)
                .setData(project.convertToDT())
            completable(.completed)
            return Disposables.create()
        }
    }
    
    func update(_ project: Project) -> Completable {
        return Completable.create { completable in
            self.dataBase
                .collection("users")
                .document(project.id.description)
                .updateData(project.convertToDT())
            completable(.completed)
            return Disposables.create()
        }
        
    }
    
    func delete(_ project: Project) -> Completable {
        return Completable.create { completable in
            self.dataBase
                .collection("users")
                .document(project.id.description)
                .delete()
            completable(.completed)
            return Disposables.create()
        }
    }
}
