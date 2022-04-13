import RxSwift

protocol DataSourceProtocol {
    func append(_ project: Project) -> Completable
    func delete(_ project: Project) -> Completable
    func update(_ project: Project) -> Completable
    func fetch() -> Single<[Project]>
}
